-- FORM Store — stored procedures (RPC)
-- Postgres / Supabase
--
-- These functions hold the transactional logic of the store:
-- stock is never checked and decremented in two separate steps,
-- order status is never advanced without a row lock,
-- and the daily try-on quota is enforced by a single atomic statement.
--
-- All of them are called from n8n over PostgREST (/rest/v1/rpc/<name>).

-- ---------------------------------------------------------------------------
-- create_order(customer, items) -> { order_id, total, status }
--
-- Creates an order and decrements stock in one transaction.
--
-- The stock guard is `WHERE stock_quantity >= v_qty` on the UPDATE itself,
-- not a SELECT followed by an UPDATE. There is no window between the check
-- and the decrement, so two shoppers buying the last item cannot both win:
-- the second UPDATE matches no rows, row_count is 0, and the whole
-- transaction is rolled back by the exception.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.create_order(p_customer jsonb, p_items jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  v_order_id   bigint;
  v_total      numeric := 0;
  v_item       jsonb;
  v_variant_id bigint;
  v_qty        int;
  v_price      numeric;
  v_updated    int;
begin
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'Empty order';
  end if;

  insert into orders (
    customer_name, customer_email, customer_phone,
    address_line1, address_line2, city, postcode, country,
    total_amount
  )
  values (
    p_customer->>'name',
    p_customer->>'email',
    p_customer->>'phone',
    p_customer->>'address_line1',
    nullif(p_customer->>'address_line2', ''),
    p_customer->>'city',
    p_customer->>'postcode',
    coalesce(p_customer->>'country', 'GR'),
    0
  )
  returning id into v_order_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_variant_id := (v_item->>'variant_id')::bigint;
    v_qty        := (v_item->>'quantity')::int;

    if v_qty is null or v_qty < 1 then
      raise exception 'Bad quantity for variant %', v_variant_id;
    end if;

    -- price is read from the database, never trusted from the client
    select p.price into v_price
    from variants v
    join products p on p.id = v.product_id
    where v.id = v_variant_id;

    if v_price is null then
      raise exception 'Unknown variant: %', v_variant_id;
    end if;

    update variants
    set stock_quantity = stock_quantity - v_qty
    where id = v_variant_id
      and stock_quantity >= v_qty;

    get diagnostics v_updated = row_count;
    if v_updated = 0 then
      raise exception 'Not enough stock for variant %', v_variant_id;
    end if;

    insert into order_items (order_id, variant_id, quantity, price_at_purchase)
    values (v_order_id, v_variant_id, v_qty, v_price);

    v_total := v_total + v_price * v_qty;
  end loop;

  update orders set total_amount = round(v_total, 2) where id = v_order_id;

  return jsonb_build_object(
    'order_id', v_order_id,
    'total',    round(v_total, 2),
    'status',   'pending'
  );
end;
$function$;


-- ---------------------------------------------------------------------------
-- release_order(order_id, status) -> boolean
--
-- Cancels or expires an unpaid order and puts the stock back.
--
-- The `AND status = 'pending'` clause is what makes this safe to call twice.
-- Stripe retries webhooks, and a checkout can expire while a cancel request
-- is already in flight. Whichever call arrives first flips the status; the
-- second matches no rows, returns false, and never restores stock twice.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.release_order(p_order_id bigint, p_status text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_updated int;
begin
  -- only pending orders can be released; anything else is a no-op
  update orders
     set status = p_status
   where id = p_order_id
     and status = 'pending';

  get diagnostics v_updated = row_count;
  if v_updated = 0 then
    return false;
  end if;

  -- return the reserved quantities to stock
  update variants v
     set stock_quantity = v.stock_quantity + oi.quantity
    from order_items oi
   where oi.order_id = p_order_id
     and oi.variant_id = v.id;

  return true;
end;
$function$;


-- ---------------------------------------------------------------------------
-- advance_order_status(order_id, to) -> { ok, status } | { ok, reason }
--
-- Moves an order through the fulfilment states: paid -> accepted -> shipped.
--
-- `SELECT ... FOR UPDATE` locks the row for the rest of the transaction.
-- The admin bot exposes inline buttons, and a double tap (or two admins)
-- would otherwise read the same status twice and apply the same transition
-- twice. With the lock, the second call sees the already-updated value and
-- is rejected as an invalid transition.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.advance_order_status(p_order_id bigint, p_to text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_from text;
begin
  select status into v_from from orders where id = p_order_id for update;

  if v_from is null then
    return jsonb_build_object('ok', false, 'reason', 'not_found');
  end if;

  if (p_to = 'accepted' and v_from = 'paid')
     or (p_to = 'shipped' and v_from = 'accepted') then
    update orders set status = p_to where id = p_order_id;
    return jsonb_build_object('ok', true, 'status', p_to);
  end if;

  return jsonb_build_object('ok', false, 'reason', 'invalid_transition', 'status', v_from);
end;
$function$;


-- ---------------------------------------------------------------------------
-- increment_vton_usage(limit) -> (allowed, used, day_limit)
--
-- Enforces the store-wide daily quota on virtual try-on generations.
-- Every generation costs real money at the FASHN API, so the counter has to
-- be reserved before the job is started, not after it succeeds.
--
-- INSERT ... ON CONFLICT DO UPDATE ... WHERE performs the read, the limit
-- check and the increment as one statement. When the WHERE fails the UPDATE
-- touches no rows, RETURNING yields nothing, and v_used stays null — which is
-- how the function detects that the quota is exhausted.
--
-- Note: this counts *attempts*, not credits. Failed jobs are not refunded to
-- the counter, deliberately — it is cheaper to be slightly strict than to
-- leave a retry loop able to drain the budget.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.increment_vton_usage(p_limit integer)
 RETURNS TABLE(allowed boolean, used integer, day_limit integer)
 LANGUAGE plpgsql
AS $function$
declare
  v_used integer;
begin
  insert into vton_usage as vu (day, generations)
  values (current_date, 1)
  on conflict (day) do update
    set generations = vu.generations + 1
    where vu.generations < p_limit
  returning vu.generations into v_used;

  if v_used is null then
    select vu2.generations into v_used
      from vton_usage vu2
     where vu2.day = current_date;
    return query select false, v_used, p_limit;
    return;
  end if;

  return query select true, v_used, p_limit;
end;
$function$;
