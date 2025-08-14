import { createClient } from '@supabase/supabase-js';

const url = process.env.NEXT_PUBLIC_SUPABASE_URL as string;
const anon = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY as string;
const service = process.env.SUPABASE_SERVICE_ROLE_KEY as string;

export const supabaseBrowser = () =>
  createClient(url, anon, { auth: { persistSession: false } });

export const supabaseServer = () =>
  createClient(url, service, { auth: { persistSession: false } });

