-- 005_fix_rls_policies.sql

-- Products: public read, admin-only write
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Allow public read access to products
CREATE POLICY products_allow_select ON public.products
  FOR SELECT USING (true);

-- Allow admin-only write access to products
CREATE POLICY products_allow_insert ON public.products
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY products_allow_update ON public.products
  FOR UPDATE USING (auth.role() = 'service_role') 
  WITH CHECK (auth.role() = 'service_role');

CREATE POLICY products_allow_delete ON public.products
  FOR DELETE USING (auth.role() = 'service_role');

-- Order Items: only accessible through orders
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Allow select if user owns the related order
CREATE POLICY order_items_allow_select ON public.order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders o 
      WHERE o.id = order_id 
      AND o.customer_id = auth.uid()::uuid
    )
  );

-- Allow insert if user owns the related order
CREATE POLICY order_items_allow_insert ON public.order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders o 
      WHERE o.id = NEW.order_id 
      AND o.customer_id = auth.uid()::uuid
    )
    OR auth.role() = 'service_role'
  );

-- Allow update if user owns the related order
CREATE POLICY order_items_allow_update ON public.order_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.orders o 
      WHERE o.id = order_id 
      AND o.customer_id = auth.uid()::uuid
    )
    OR auth.role() = 'service_role'
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders o 
      WHERE o.id = NEW.order_id 
      AND o.customer_id = auth.uid()::uuid
    )
    OR auth.role() = 'service_role'
  );

-- Allow delete if user owns the related order
CREATE POLICY order_items_allow_delete ON public.order_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.orders o 
      WHERE o.id = order_id 
      AND o.customer_id = auth.uid()::uuid
    )
    OR auth.role() = 'service_role'
  );

-- View Order Summary: RLS follows orders access
ALTER VIEW public.vw_order_summary SECURITY DEFINER;

-- Allow select from view if user owns the order
CREATE POLICY vw_order_summary_select ON public.vw_order_summary
  FOR SELECT USING (
    customer_id = auth.uid()::uuid
    OR auth.role() = 'service_role'
  );