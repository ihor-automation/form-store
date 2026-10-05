# Try-on service

Module 6 of FORM Store, split out so that a shop which is not FORM Store can use it. One hosted n8n workflow and one static page serve any number of shops; a shop is a row in a table and a link.

Unlike the storefront, this part is deployed: the workflow runs on a hosted n8n instance (Railway) and the page is a static file on Netlify.

```
Shopper ⇄ fitting-room page (?shop=<id>) ⇄ [3 webhooks] ⇄ n8n
                                                           ├── Supabase   shops, their products, per-shop usage
                                                           └── FASHN      virtual try-on
```

The shop's own website is not touched. The shop gets a link; whether it sits behind a "Try it on" button, in an Instagram bio or in a message is up to the shop.

---

## What is in this folder

```
page/index.html    the fitting room: one file, no framework, no build step
workflows/         the n8n workflow, downloaded from the hosted instance
db/schema.sql      tryon_shops, tryon_products, tryon_usage
db/functions.sql   increment_tryon_usage, tryon_shop_catalog
```

The workflow file carries credential names and ids, not their contents; it was checked for keys before it was committed.

The storefront's own try-on (`/workflows/M6 - Virtual Try-On.json`, `vton_usage`) is the single-shop original and still works on its own. This folder is its multi-shop successor, not a replacement.

---

## How a try-on runs

**1. The page opens a shop.** `GET /tryon-products?shop=<id>` calls `tryon_shop_catalog` and returns the shop's active items. Without a shop id, or with an unknown or switched-off one, the page shows a closed screen and nothing else.

**2. The shopper picks an item and a photo.** Items are grouped by `photo_type` (tops, bottoms, dresses, shoes, bags), and each group carries its own advice on what photo to use — a waist-up shot for a shirt, legs and feet for shoes. The photo is shrunk in the browser to 1600 px on the long side before upload.

**3. The job starts.** `POST /tryon-start` with the shop id, the product id and the photo:

```
Check daily limit → Limit OK? → Get product image → Product OK? → FASHN start → Respond job started
                        └ 429 daily_limit / shop_not_available     └ 400 vton_not_available
```

**4. The page polls.** `POST /tryon-status` every three seconds until the job is `completed` or `failed`. A dropped poll is not treated as a failure; the page gives up after 150 seconds.

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

## Running your own copy

**1. Database.** In the Supabase SQL editor run `db/schema.sql`, then `db/functions.sql`.

**2. Workflow.** Import the file from `workflows/` into n8n and create two credentials: a **Custom Auth** credential carrying a Supabase secret (service-role) key, and a **Header Auth** credential carrying the FASHN key. Replace the Supabase project URL in the three HTTP nodes with your own, then publish the workflow.

**3. Page.** Set `API` at the top of the script in `page/index.html` to your n8n webhook base URL, put your own contact details in the dialog near the end of the markup (the WhatsApp number in this copy is a placeholder), and host the file anywhere that serves static files.

---

## Limitations

- **The per-person limit is soft.** Five try-ons per device per day, kept in `localStorage`; a private window resets it. The shop's daily cap on the server is the real budget control.
- **The webhooks are public.** Anyone who has a shop's id can start try-ons for it until that shop's daily cap is reached.
- **No table stores shopper photos.** A photo does travel through n8n on its way to the try-on provider, so whether a copy remains in n8n's execution history depends on that instance's execution-saving settings.
- **`tryon_prompt` is not wired in yet.** The column exists and the workflow reads it, but the request to the try-on API does not include it.
- **Try-on does not model fit.** It shows how an item looks, not how a size sits, and the page says so.
- **Catalogues are entered by hand.** There is no sync with a shop's own product feed.
- **Results live 72 hours** on the provider's CDN.
