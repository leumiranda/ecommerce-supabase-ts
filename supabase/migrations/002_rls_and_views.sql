-- 002_rls_and_views.sql
-- Add RLS policies for customers/users and orders

-- Enable RLS on tables
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
-- Policies: allow authenticated users to access their own rows

-- customers: owners may select their row
-- customers policies
DROP POLICY IF EXISTS customers_select_owner ON public.customers;
CREATE POLICY customers_select_owner ON public.customers
  FOR SELECT USING (id = auth.uid()::uuid);

DROP POLICY IF EXISTS customers_insert_owner ON public.customers;
CREATE POLICY customers_insert_owner ON public.customers
  FOR INSERT WITH CHECK (id = auth.uid()::uuid);

DROP POLICY IF EXISTS customers_update_owner ON public.customers;
CREATE POLICY customers_update_owner ON public.customers
  FOR UPDATE USING (id = auth.uid()::uuid) WITH CHECK (id = auth.uid()::uuid);

-- users policies
DROP POLICY IF EXISTS users_select_owner ON public.users;
CREATE POLICY users_select_owner ON public.users
  FOR SELECT USING (id = auth.uid()::uuid);

DROP POLICY IF EXISTS users_update_owner ON public.users;
CREATE POLICY users_update_owner ON public.users
  FOR UPDATE USING (id = auth.uid()::uuid) WITH CHECK (id = auth.uid()::uuid);

-- orders policies
DROP POLICY IF EXISTS orders_select_owner ON public.orders;
CREATE POLICY orders_select_owner ON public.orders
  FOR SELECT USING (customer_id = auth.uid()::uuid);

DROP POLICY IF EXISTS orders_insert_owner ON public.orders;
CREATE POLICY orders_insert_owner ON public.orders
  FOR INSERT WITH CHECK (customer_id = auth.uid()::uuid);

DROP POLICY IF EXISTS orders_update_owner ON public.orders;
CREATE POLICY orders_update_owner ON public.orders
  FOR UPDATE USING (customer_id = auth.uid()::uuid) WITH CHECK (customer_id = auth.uid()::uuid);

-- Views
CREATE OR REPLACE VIEW public.vw_order_summary AS
SELECT o.id as order_id, o.customer_id, o.status, o.total, o.created_at,
  json_agg(json_build_object('product_id', oi.product_id, 'quantity', oi.quantity, 'unit_price', oi.unit_price)) as items
FROM public.orders o
LEFT JOIN public.order_items oi ON oi.order_id = o.id
GROUP BY o.id;
