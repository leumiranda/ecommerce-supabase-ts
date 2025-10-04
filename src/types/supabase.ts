export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      customers: {
        Row: {
          id: string
          name: string
          email: string
          created_at: string
          // adicione outros campos conforme necessário
        }
        Insert: {
          id?: string
          name: string
          email: string
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          email?: string
          created_at?: string
        }
      }
      products: {
        Row: {
          id: string
          name: string
          description: string
          price: number
          stock: number
          created_at: string
          // adicione outros campos conforme necessário
        }
        Insert: {
          id?: string
          name: string
          description: string
          price: number
          stock: number
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string
          price?: number
          stock?: number
          created_at?: string
        }
      }
      orders: {
        Row: {
          id: string
          customer_id: string
          total: number
          status: string
          created_at: string
          // adicione outros campos conforme necessário
        }
        Insert: {
          id?: string
          customer_id: string
          total?: number
          status?: string
          created_at?: string
        }
        Update: {
          id?: string
          customer_id?: string
          total?: number
          status?: string
          created_at?: string
        }
      }
      order_items: {
        Row: {
          id: string
          order_id: string
          product_id: string
          quantity: number
          unit_price: number
          created_at: string
          // adicione outros campos conforme necessário
        }
        Insert: {
          id?: string
          order_id: string
          product_id: string
          quantity: number
          unit_price: number
          created_at?: string
        }
        Update: {
          id?: string
          order_id?: string
          product_id?: string
          quantity?: number
          unit_price?: number
          created_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      recalc_order_total: {
        Args: { o_id: string }
        Returns: { total: number }
      }
    }
    Enums: {
      [_ in never]: never
    }
  }
}