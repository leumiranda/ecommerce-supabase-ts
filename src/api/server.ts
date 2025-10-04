import express, { Request, Response, NextFunction } from "express";
import dotenv from "dotenv";
import { supabase, supabaseAdmin } from "../db/db";
import swaggerUi from 'swagger-ui-express'
import openapi from '../../openapi.json'
import { RequestWithSupabase } from "../types/types";

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Swagger UI (OpenAPI)
app.use('/docs', swaggerUi.serve, swaggerUi.setup(openapi as any))

// Middleware: adiciona o Supabase ao request
// Middleware: adiciona o Supabase ao request e permite desativar RLS com ?rls=false ou header x-rls-enabled=false
app.use((req: Request, _res: Response, next: NextFunction) => {
  const rlsHeader = String(req.headers['x-rls-enabled'] ?? 'true')
  const rlsQuery = String(req.query.rls ?? 'true')
  const rlsEnabled = !(rlsHeader === 'false' || rlsQuery === 'false')

  // se RLS estiver desativado e supabaseAdmin disponível, usamos o client admin
  ;(req as RequestWithSupabase).supabase = !rlsEnabled && supabaseAdmin ? supabaseAdmin : supabase
  ;(req as any).rlsEnabled = rlsEnabled
  next();
});

// ------------------------------------------------------------
// Customers
// ------------------------------------------------------------
app.get("/customers", async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any
  // prefer admin client when available to bypass RLS for internal endpoints
  const client = (supabaseAdmin ?? db) as any
  const { data, error } = await client.from("customers").select("*");
  console.log('/customers using', supabaseAdmin ? 'supabaseAdmin' : 'anon', 'rows=', Array.isArray(data) ? data.length : 0)

  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post("/customers", async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any
  const { data, error } = await db
    .from("customers")
    .insert([req.body])
    .select("*")
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

// ------------------------------------------------------------
// Products
// ------------------------------------------------------------
app.get("/products", async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any
  const { data, error } = await db.from("products").select("*");

  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post("/products", async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any
  const { data, error } = await db
    .from("products")
    .insert([req.body])
    .select("*")
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

app.put("/products/:id", async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any
  const { data, error } = await db
    .from("products")
    .update(req.body)
    .eq("id", req.params.id)
    .select("*")
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.delete("/products/:id", async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any
  const { error } = await db
    .from("products")
    .delete()
    .eq("id", req.params.id);

  if (error) return res.status(500).json({ error: error.message });
  res.status(204).end();
});

// ------------------------------------------------------------
// Orders
// ------------------------------------------------------------
app.get("/orders", async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any
  const status = String(req.query.status || '').trim()

  // If a status filter is provided, apply it (e.g. ?status=pending or ?status=approved)
  let query = db.from("orders").select("*")
  if (status) {
    query = query.eq('status', status)
  }

  const { data, error } = await query;

  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post("/orders", async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any
  const { customer_id, items } = req.body;

  if (!customer_id || !items || !Array.isArray(items)) {
    return res.status(400).json({ error: "Invalid order payload" });
  }

  // cria o pedido
  const { data: order, error: orderError } = await db
    .from("orders")
    .insert([{ customer_id }])
    .select("*")
    .single();

  if (orderError) return res.status(500).json({ error: orderError.message });

  // cria os itens do pedido
  const orderItems = items.map((item: any) => ({
    order_id: order.id,
    product_id: item.product_id,
    quantity: item.quantity,
  }));

  const { data: itemsData, error: itemsError } = await db
    .from("order_items")
    .insert(orderItems)
    .select("*");

  if (itemsError) return res.status(500).json({ error: itemsError.message });

  res.status(201).json({ order, items: itemsData });
});

// Approve an order (server-side action)
app.post('/orders/:id/approve', async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any
  const orderId = req.params.id

  // Check order exists
  const { data: existing, error: fetchErr } = await db.from('orders').select('*').eq('id', orderId).single()
  if (fetchErr) return res.status(500).json({ error: fetchErr.message })
  if (!existing) return res.status(404).json({ error: 'Order not found' })

  // Update status to 'approved'
  const { data: updated, error: updateErr } = await db.from('orders').update({ status: 'approved' }).eq('id', orderId).select('*').single()
  if (updateErr) return res.status(500).json({ error: updateErr.message })

  // Recalculate totals (calls SQL function)
  try {
    await db.rpc('recalc_order_total', { o_id: orderId })
  } catch (e: any) {
    // not fatal
    console.warn('recalc_order_total RPC failed', e?.message || e)
  }

  return res.json(updated)
})

// Dedicated endpoint to list pending orders
app.get('/orders/pending', async (req: Request, res: Response) => {
  const r = req as RequestWithSupabase
  const db = r.supabase as any

  const { data, error } = await db.from('orders').select('*').eq('status', 'pending')

  if (error) return res.status(500).json({ error: error.message })
  return res.json(data)
})

export default app;
