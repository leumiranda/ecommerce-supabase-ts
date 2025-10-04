import { Request } from "express";
import { SupabaseClient } from "@supabase/supabase-js";

export interface RequestWithSupabase extends Request {
  supabase: SupabaseClient;
}