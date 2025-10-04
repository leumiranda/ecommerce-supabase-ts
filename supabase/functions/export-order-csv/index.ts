// Edge Function (Deno) - export-order-csv
import { serve } from 'std/server'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const client = createClient(supabaseUrl, supabaseKey)

serve(async (req) => {
  try {
    const { orderId } = await req.json()
    if (!orderId) return new Response('orderId required', { status: 400 })

    const { data: order } = await client.from('orders').select('*').eq('id', orderId).single()
    const { data: items } = await client.from('order_items').select('*').eq('order_id', orderId)

    const rows = items?.map((it: any) => ({ product_id: it.product_id, quantity: it.quantity, unit_price: it.unit_price })) || []
    const header = 'product_id,quantity,unit_price\n'
    const csv = header + rows.map((r: any) => `${r.product_id},${r.quantity},${r.unit_price}`).join('\n')

    return new Response(csv, {
      status: 200,
      headers: {
        'content-type': 'text/csv; charset=utf-8',
        'content-disposition': `attachment; filename="order-${orderId}.csv"`
      }
    })
  } catch (err) {
    return new Response(String(err), { status: 500 })
  }
})
