# Try-on service

Module 6 of FORM Store, split out so that a shop which is not FORM Store can use it. One hosted n8n workflow and one static page serve any number of shops; a shop is a row in a table and a link.

Unlike the storefront, this part is deployed: the workflow runs on a hosted n8n instance (Railway) and the page is a static file on Netlify.

```
Shopper ⇄ fitting-room page (?shop=<id>) ⇄ [3 webhooks] ⇄ n8n
                                                           ├── Supabase   shops, products, per-shop usage, try-on log
                                                           ├── FASHN      virtual try-on
                                                           └── Telegram   failure alerts, from a separate error workflow
```

The shop's own website is not touched. The shop gets a link; whether it sits behind a "Try it on" button, in an Instagram bio or in a message is up to the shop.

---

## What is in this folder

```
page/index.html    the fitting room: one file, no framework, no build step
workflows/         the try-on workflow and its error workflow, downloaded from the hosted instance
db/schema.sql      tryon_shops, tryon_products, tryon_usage, tryon_log
db/functions.sql   increment_tryon_usage, tryon_shop_catalog
```

The workflow files carry credential names and ids, not their contents; they were checked for keys before they were committed. The Telegram chat id in `Error Handler.json` is a placeholder.

The storefront's own try-on (`/workflows/M6 - Virtual Try-On.json`, `vton_usage`) is the single-shop original and still works on its own. This folder is its multi-shop successor, not a replacement.

---

## How a try-on runs

**1. The page opens a shop.** `GET /tryon-products?shop=<id>` calls `tryon_shop_catalog` and returns the shop's active items. Without a shop id, or with an unknown or switched-off one, the page shows a closed screen and nothing else.

**2. The shopper picks an item and a photo.** Items are grouped by `photo_type` (tops, bottoms, dresses, shoes, bags), and each group carries its own advice on what photo to use — a waist-up shot for a shirt, legs and feet for shoes. The photo is shrunk in the browser to 1600 px on the long side before upload.

**3. The job starts.** `POST /tryon-start` with the shop id, the product id and the photo:

```
Check daily limit → Limit OK? → Get product image → Product OK? → FASHN start → Respond job started → Log start
                        └ 429 daily_limit / shop_not_available     └ 400 vton_not_available
```

**4. The page polls.** `POST /tryon-status` every three seconds until the job is `completed` or `failed`. A dropped poll is not treated as a failure; the page gives up after 150 seconds. On a final status the workflow answers the page first and then records the outcome in `tryon_log` (`Log done` or `Log failed`).

**5. If a node fails,** n8n runs `Error Handler`, which sends the workflow name, the failing node and the error message to the owner's Telegram.

---

## Engineering decisions

### The limit lives on the shop's row

In the storefront the daily cap is a number the workflow passes in. With several shops that would mean the workflow deciding each shop's budget, so here the caller sends only a shop id and `increment_tryon_usage` reads `daily_limit` from that shop's row. The check and the increment are still one statement:

```sql
insert into tryon_usage (shop_id, day, generations)
values (v_shop_id, current_date, 1)
on conflict (shop_id, day)
do update set generations = tryon_usage.generations + 1
where tryon_usage.generations < v_limit
returning generations into v_used;
```

One shop running out does not affect another, and the worst day for any shop is `daily_limit × $0.15`. The default is 10.

### The shop id arrives as text

The webhooks are public, so the id is whatever a stranger put in a URL. Declared as `uuid`, a malformed value would make Postgres raise before the function body runs, and the caller would see a database error. Both functions take `text` and compare `id::text`, so `not-a-uuid` gets the same answer as a shop that does not exist.

### A product is looked up together with its shop

`Get product image` filters on `id`, `shop_id` and `is_active` at once. A product id that belongs to another shop returns nothing, so one shop's link cannot be used to try on another shop's catalogue.

### Switching a shop off is one column

`is_active = false` closes the fitting room and stops the spend, and keeps the catalogue and the usage history. Deleting the row removes its products and usage with it (`ON DELETE CASCADE`).

### Unknown and inactive shops look the same

`tryon_shop_catalog` answers `shop_not_available` in both cases. The page cannot be used to find out which ids exist.

### The log is written after the answer

`Log start`, `Log done` and `Log failed` sit after the nodes that answer the page. The shopper gets the result first, so a slow or failed write to the log cannot delay or break a try-on. The log nodes keep n8n's default stop-on-error on purpose: a failed write does not reach the shopper, but it does reach the error workflow, so the owner hears about it.

### An outcome is recorded once

The page asks for the status every three seconds, and anyone can ask about an old job id. The update filters on `status=eq.started` as well as the job id, so only the first final answer changes the row and every later request matches nothing — the same idea as the stock guard in the store: the condition is part of the write.

The provider's error text is passed through `JSON.stringify` before it goes into the request body, so quotes inside an error message cannot break the JSON.

### Execution history lives 24 hours

n8n keeps successful and failed executions so a fault can be traced, and the instance prunes them after 24 hours (`EXECUTIONS_DATA_MAX_AGE=24`). The request body — the shopper's photo included — is part of an execution, so this setting is what decides how long a photo stays on the server. The long-term record is `tryon_log`, which keeps what happened but not who it happened to.

---

## Adding a shop

```sql
with s as (
  insert into tryon_shops (name) values ('Shop name') returning id
)
insert into tryon_products (shop_id, name, image_url, photo_type)
select s.id, v.name, v.image_url, v.photo_type
from s, (values
  ('Linen shirt', 'https://…/shirt.jpg', 'top'),
  ('Midi dress',  'https://…/dress.jpg', 'dress')
) as v(name, image_url, photo_type)
returning shop_id;
```

The returned id goes into the link: `https://<page host>/?shop=<id>`.

---

## Reading the log

```sql
select p.name,
       count(*) as tries,
       count(*) filter (where l.status = 'completed') as ok,
       count(*) filter (where l.status = 'failed') as failed,
       round(avg(extract(epoch from l.finished_at - l.created_at))) as avg_seconds
from tryon_log l
left join tryon_products p on p.id = l.product_id
group by p.name
order by tries desc;
```

Tries, outcomes and average wait per item.

---

## Running your own copy

**1. Database.** In the Supabase SQL editor run `db/schema.sql`, then `db/functions.sql`.

**2. Workflows.** Import both files from `workflows/` into n8n and create three credentials: a **Custom Auth** credential carrying a Supabase secret (service-role) key, a **Header Auth** credential carrying the FASHN key, and a **Telegram** credential carrying a bot token. Replace the Supabase project URL in the six HTTP nodes with your own, put your Telegram chat id into `Error Handler`, select `Error Handler` as the error workflow in the try-on workflow's settings, then publish the try-on workflow. The error workflow does not need publishing.

**3. Execution history.** On the n8n instance set `EXECUTIONS_DATA_PRUNE=true` and `EXECUTIONS_DATA_MAX_AGE=24`.

**4. Page.** Set `API` at the top of the script in `page/index.html` to your n8n webhook base URL, put your own contact details in the dialog near the end of the markup (the WhatsApp number in this copy is a placeholder), and host the file anywhere that serves static files.

---

## Limitations

- **The per-person limit is soft.** Five try-ons per device per day, kept in `localStorage`; a private window resets it. The shop's daily cap on the server is the real budget control.
- **The webhooks are public.** Anyone who has a shop's id can start try-ons for it until that shop's daily cap is reached.
- **Photos are kept for about a day.** No table stores them, but they travel through n8n, whose execution history is kept 24 hours for troubleshooting. The page tells shoppers that photos and results are deleted within 3 days, the result images being kept 3 days by the try-on provider.
- **`tryon_prompt` is not wired in yet.** The column exists and the workflow reads it, but the request to the try-on API does not include it.
- **Try-on does not model fit.** It shows how an item looks, not how a size sits, and the page says so.
- **Catalogues are entered by hand.** There is no sync with a shop's own product feed.
- **Results live 72 hours** on the provider's CDN.
