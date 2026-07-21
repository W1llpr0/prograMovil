-- Supabase Cloud installs pgcrypto in the extensions schema. Include it in the
-- execution path so complete_consultation can resolve digest() consistently in
-- hosted Supabase and vanilla PostgreSQL.

alter function public.complete_consultation(
  bigint, text, text, text, boolean, jsonb, jsonb
) set search_path = public, extensions;
