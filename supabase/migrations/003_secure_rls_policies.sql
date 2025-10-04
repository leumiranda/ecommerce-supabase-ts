-- 003_secure_rls_policies.sql
-- More secure RLS policies

-- Notes:
-- - Supabase exposes `auth.uid()` (text) and `auth.role()` inside policy expressions.
-- - To allow administrative actions from client JWTs, you can add a custom claim `is_admin` to the user's JWT and check it with `current_setting('jwt.claims.is_admin', true) = 'true'`.

-- CUSTOMERS / USERS: owner-only access
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- customers: owners may select their row
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='customers' AND policyname='customers_select_owner') THEN
    CREATE POLICY customers_select_owner ON public.customers
      FOR SELECT USING (id = auth.uid()::uuid);
  END IF;
END$$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='customers' AND policyname='customers_insert_owner') THEN
    CREATE POLICY customers_insert_owner ON public.customers
      FOR INSERT WITH CHECK (NEW.id = auth.uid()::uuid);
  END IF;
END$$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='customers' AND policyname='customers_update_owner') THEN
    CREATE POLICY customers_update_owner ON public.customers
      FOR UPDATE USING (id = auth.uid()::uuid) WITH CHECK (NEW.id = auth.uid()::uuid);
  END IF;
END$$;

-- users: owner-only (if you store auth users in users table)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='users' AND policyname='users_select_owner') THEN
    CREATE POLICY users_select_owner ON public.users
      FOR SELECT USING (id = auth.uid()::uuid);
  END IF;
END$$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='users' AND policyname='users_update_owner') THEN
    CREATE POLICY users_update_owner ON public.users
      FOR UPDATE USING (id = auth.uid()::uuid) WITH CHECK (NEW.id = auth.uid()::uuid);
  END IF;
END$$;

-- ORDERS: owner-only access; allow insert when customer_id matches JWT
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='orders' AND policyname='orders_select_owner') THEN
    CREATE POLICY orders_select_owner ON public.orders
      FOR SELECT USING (customer_id = auth.uid()::uuid);
  END IF;
END$$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='orders' AND policyname='orders_insert_owner') THEN
    CREATE POLICY orders_insert_owner ON public.orders
      FOR INSERT WITH CHECK (NEW.customer_id = auth.uid()::uuid);
  END IF;
END$$;

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
