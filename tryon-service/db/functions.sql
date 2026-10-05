-- Try-on service — stored procedures (RPC)
-- Postgres / Supabase
--
-- Both functions are called from n8n over PostgREST (/rest/v1/rpc/<name>).
--
-- Both take the shop id as text, not uuid. The webhooks are public, so the
-- value arriving here is whatever a stranger typed into a URL. A uuid
-- parameter would make Postgres raise on a malformed value before the function
-- body runs; comparing id::text lets a bad id fall through to the ordinary
-- "shop not available" answer.

-- ---------------------------------------------------------------------------
-- increment_tryon_usage(shop_id) -> { allowed, used, day_limit } | { allowed, reason }
--
-- Enforces a shop's daily quota of try-on generations. Every generation costs
-- real money at the FASHN API, so the slot is reserved before the job is
-- started, not after it succeeds.
--
-- INSERT ... ON CONFLICT DO UPDATE ... WHERE performs the read, the limit
-- check and the increment as one statement. When the WHERE fails the UPDATE
-- touches no rows, RETURNING yields nothing, and v_used stays null — which is
-- how the function detects that the quota is exhausted.
--
-- The limit comes from the shop's own row, not from the caller: the workflow
-- cannot be talked into a higher limit by a crafted request. An unknown or
-- inactive shop is refused before anything is counted.
--
-- Note: this counts *attempts*, not credits. Failed jobs are not refunded to
-- the counter, deliberately — it is cheaper to be slightly strict than to
-- leave a retry loop able to drain the budget.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.increment_tryon_usage(p_shop_id text)
 RETURNS json
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_shop_id uuid;
  v_limit integer;
  v_used integer;
begin
  select id, daily_limit into v_shop_id, v_limit
  from tryon_shops
  where id::text = p_shop_id and is_active;

  if v_shop_id is null or v_limit < 1 then
    return json_build_object('allowed', false, 'reason', 'shop_not_available');
  end if;

  insert into tryon_usage (shop_id, day, generations)
  values (v_shop_id, current_date, 1)
  on conflict (shop_id, day)
  do update set generations = tryon_usage.generations + 1
  where tryon_usage.generations < v_limit
  returning generations into v_used;

  if v_used is null then
    return json_build_object('allowed', false, 'reason', 'daily_limit', 'day_limit', v_limit);
  end if;

  return json_build_object('allowed', true, 'used', v_used, 'day_limit', v_limit);
end;
$function$;


-- ---------------------------------------------------------------------------
-- tryon_shop_catalog(shop_id) -> { ok, shop, products[] } | { ok: false, error }
--
-- Everything the fitting-room page needs to render a shop, in one call: the
-- shop's name and its active products, ordered by photo_type so the page can
-- group them without sorting.
--
-- The outer coalesce is what makes "no such shop" and "shop switched off" look
-- identical to the caller. The inner one returns an empty array for a shop
-- with no active products, rather than null.
--
-- tryon_prompt is deliberately left out: it is internal to the workflow and
-- has no reason to reach the browser.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tryon_shop_catalog(p_shop_id text)
 RETURNS json
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select coalesce(
    (
      select json_build_object(
        'ok', true,
        'shop', s.name,
        'products', coalesce(
          (
            select json_agg(
              json_build_object(
                'id', p.id,
                'name', p.name,
                'image_url', p.image_url,
                'photo_type', p.photo_type
              )
              order by p.photo_type, p.id
            )
            from tryon_products p
            where p.shop_id = s.id and p.is_active
          ),
          '[]'::json
        )
      )
      from tryon_shops s
      where s.id::text = p_shop_id and s.is_active
    ),
    json_build_object('ok', false, 'error', 'shop_not_available')
  );
$function$;
