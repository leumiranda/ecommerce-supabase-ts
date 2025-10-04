Edge Functions

- send-order-confirmation: fetches an order and customer and simulates sending an email (Deno).
- export-order-csv: returns a CSV file for a given orderId (Deno).

To deploy with Supabase CLI:

supabase functions deploy send-order-confirmation --project-ref <ref>
supabase functions deploy export-order-csv --project-ref <ref>

To test locally with Deno:

DENONOTE: requires Deno and supabase CLI/local config

