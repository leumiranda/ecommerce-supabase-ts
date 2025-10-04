-- Migration: create basic ecommerce tables
-- Ensure extensions for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- customers
CREATE TABLE IF NOT EXISTS public.customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  name text,
  created_at timestamptz DEFAULT now()
);

-- products
CREATE TABLE IF NOT EXISTS public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sku text UNIQUE NOT NULL,
  name text NOT NULL,
  description text,
  price numeric(10,2) NOT NULL DEFAULT 0,
  stock integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- orders
CREATE TABLE IF NOT EXISTS public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid REFERENCES public.customers(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'pending',
  total numeric(10,2) NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- order_items
CREATE TABLE IF NOT EXISTS public.order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id) ON DELETE SET NULL,
  quantity integer NOT NULL DEFAULT 1,
  unit_price numeric(10,2) NOT NULL DEFAULT 0
);

-- Function: recalc_order_total
CREATE OR REPLACE FUNCTION public.recalc_order_total(o_id uuid)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE public.orders
  SET total = (SELECT COALESCE(SUM(unit_price * quantity),0) FROM public.order_items WHERE order_id = o_id)
  WHERE id = o_id;
END;
$$;

-- Trigger: after insert/update/delete on order_items -> recalc order total
CREATE OR REPLACE FUNCTION public.order_items_notify()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM public.recalc_order_total(NEW.order_id);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_order_items_recalc ON public.order_items;
CREATE TRIGGER trg_order_items_recalc
AFTER INSERT OR UPDATE OR DELETE ON public.order_items
FOR EACH ROW EXECUTE FUNCTION public.order_items_notify();

-- Enable RLS placeholders (we'll add policies separately)
-- For now create minimal policies allowing authenticated usage when RLS is enabled.

-- Ensure pgcrypto extension for gen_random_uuid
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- Habilita extensão para UUID
create extension if not exists "uuid-ossp";

-- Tabela de usuários
create table if not exists users (
  id uuid primary key default gen_random_uuid(),
    email text not null unique,
    password text not null,
    name text,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);

-- Tabela de produtos
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
    name text not null,
    description text,
    price numeric(10,2) not null,
    stock int default 0,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);

-- Tabela de pedidos
create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
    user_id uuid references users(id) on delete cascade,
    status text default 'pending', -- pending, paid, shipped, cancelled
    total numeric(10,2) default 0,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);

-- Tabela de itens de pedidos
create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
    order_id uuid references orders(id) on delete cascade,
    product_id uuid references products(id) on delete restrict,
    quantity int not null default 1,
    price numeric(10,2) not null,
    created_at timestamp with time zone default now()
);
