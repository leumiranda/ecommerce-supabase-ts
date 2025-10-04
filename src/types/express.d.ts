import { SupabaseClient } from '@supabase/supabase-js'
import { Request } from 'express'
import { Database } from './supabase'

export interface RequestWithSupabase extends Request {
  supabaseClient: SupabaseClient<Database, 'public'>
}