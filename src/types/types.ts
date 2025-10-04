import { Request, Response, RequestHandler } from 'express'
import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../types/supabase'

export interface RequestWithSupabase extends Request {
  supabase: SupabaseClient<Database>
}

export type Tables = Database['public']['Tables']

export type Customer = Tables['customers']['Row']
export type Product = Tables['products']['Row']
export type Order = Tables['orders']['Row']
export type OrderItem = Tables['order_items']['Row']

export type NewCustomer = Tables['customers']['Insert']
export type NewProduct = Tables['products']['Insert']
export type NewOrder = Tables['orders']['Insert']
export type NewOrderItem = Tables['order_items']['Insert']