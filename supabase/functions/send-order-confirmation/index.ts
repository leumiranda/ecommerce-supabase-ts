// Example Edge Function: send-order-confirmation
// This is a stub. In a real project you'd integrate with an email provider.

import { serve } from 'std/server'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const client = createClient(supabaseUrl, supabaseKey)

serve(async (req) => {
  try {
    const payload = await req.json()
    const orderId = payload?.orderId
    if (!orderId) return new Response('orderId required', { status: 400 })

    const { data: order, error: oErr } = await client.from('orders').select('*').eq('id', orderId).single()
    if (oErr) return new Response(JSON.stringify({ error: oErr }), { status: 500 })

    const { data: items } = await client.from('order_items').select('*').eq('order_id', orderId)
    const { data: customer } = await client.from('customers').select('*').eq('id', order.customer_id).single()

    // Simulate email sending — in production, integrate with SendGrid/Mailgun
    const emailBody = `Order ${orderId} confirmation for ${customer?.email || 'unknown'}\nTotal: ${order.total}\nItems:\n${items?.map((i: any) => `- ${i.product_id} x${i.quantity} @ ${i.unit_price}`).join('\n')}`

    // For now return the email body as response and log it
    console.log('Simulated send email:', emailBody)

    return new Response(JSON.stringify({ status: 'sent-simulated', emailBody }), { status: 200 })
  } catch (err) {
    return new Response(String(err), { status: 500 })
  }
})
