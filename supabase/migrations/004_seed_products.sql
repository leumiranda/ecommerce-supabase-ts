-- 004_seed_products.sql
INSERT INTO public.products (id, sku, name, description, price, stock)
VALUES
  (gen_random_uuid(), 'SKU-001', 'Camiseta', 'Camiseta 100% algodao, tamanho M', 49.9, 10),
  (gen_random_uuid(), 'SKU-002', 'Caneca', 'Caneca ceramica 300ml', 29.5, 25),
  (gen_random_uuid(), 'SKU-003', 'Boné', 'Boné ajustável', 39.0, 15)
ON CONFLICT (sku) DO NOTHING;
