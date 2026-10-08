-- Try-on service — database schema
-- Postgres / Supabase
--
-- Run this first, then functions.sql. These tables are separate from the
-- FORM Store tables in /db: the service reads no store table and the store
-- reads none of these, so either can be installed without the other.
--
-- Reconstructed from the live database (information_schema.columns and
-- pg_constraint). Only primary-key and unique indexes exist.

-- ---------------------------------------------------------------------------
-- tryon_shops
--
-- One row per client shop. The id is a random uuid on purpose: it is the only
-- thing in the shopper-facing link (?shop=<id>), so it has to be unguessable.
--
-- is_active is the off switch. Turning a shop off closes its fitting room and
-- stops its spend without deleting its catalogue or its usage history.
-- daily_limit is that shop's budget, in try-on attempts per calendar day.
-- ---------------------------------------------------------------------------
CREATE TABLE public.tryon_shops (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name         text NOT NULL,
  is_active    boolean NOT NULL DEFAULT true,
  daily_limit  integer NOT NULL DEFAULT 10,
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- tryon_products
--
-- The garments a shop offers for try-on. A plain bigint id is enough here: a
-- product is only ever looked up together with its shop_id, and the shop is
-- already protected by its uuid.
--
-- photo_type decides which group the item is listed under on the page and
-- which photo advice the shopper sees before uploading. The CHECK keeps it to
-- the five groups the page knows how to explain.
-- tryon_prompt is an optional per-garment prompt, null for most items. The
-- workflow reads it but does not send it to the try-on API yet.
-- ---------------------------------------------------------------------------
CREATE TABLE public.tryon_products (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  shop_id       uuid NOT NULL REFERENCES public.tryon_shops(id) ON DELETE CASCADE,
  name          text NOT NULL,
  image_url     text NOT NULL,
  tryon_prompt  text,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  photo_type    text NOT NULL DEFAULT 'top',
  CONSTRAINT tryon_products_photo_type_check
    CHECK (photo_type IN ('top', 'bottom', 'dress', 'shoes', 'bag'))
);

-- ---------------------------------------------------------------------------
-- tryon_usage
--
-- One row per shop per calendar day, holding the number of try-ons started.
-- The composite primary key is what makes increment_tryon_usage work: it
-- relies on ON CONFLICT (shop_id, day) to turn read-check-write into a single
-- atomic statement, separately for every shop.
-- ---------------------------------------------------------------------------
CREATE TABLE public.tryon_usage (
  shop_id      uuid NOT NULL REFERENCES public.tryon_shops(id) ON DELETE CASCADE,
  day          date NOT NULL DEFAULT CURRENT_DATE,
  generations  integer NOT NULL DEFAULT 0,
  PRIMARY KEY (shop_id, day)
);

-- ---------------------------------------------------------------------------
-- tryon_log
--
-- One row per try-on that reached the try-on API: which shop, which item,
-- the provider's job id, how it ended and when. It is the service's own
-- record of what happened, and it deliberately holds no photo and no IP.
--
-- product_id is SET NULL on delete, not CASCADE: taking an item out of the
-- catalogue should not erase the history of how often it was tried on.
-- job_id is UNIQUE because the outcome is written by finding the row through
-- it, and that has to match exactly one row.
-- ---------------------------------------------------------------------------
CREATE TABLE public.tryon_log (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  shop_id      uuid NOT NULL REFERENCES public.tryon_shops(id) ON DELETE CASCADE,
  product_id   bigint REFERENCES public.tryon_products(id) ON DELETE SET NULL,
  job_id       text NOT NULL UNIQUE,
  status       text NOT NULL DEFAULT 'started'
    CHECK (status IN ('started', 'completed', 'failed')),
  error        text,
  created_at   timestamptz NOT NULL DEFAULT now(),
  finished_at  timestamptz
);

-- ---------------------------------------------------------------------------
-- Row level security
--
-- Enabled on all four tables with no policies, which blocks the anon and
-- authenticated roles completely. n8n connects with the service-role key,
-- which bypasses RLS, so the browser can reach this data only through the
-- webhooks.
-- ---------------------------------------------------------------------------
ALTER TABLE public.tryon_shops    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tryon_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tryon_usage    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tryon_log      ENABLE ROW LEVEL SECURITY;
