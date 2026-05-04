DROP INDEX IF EXISTS users_supabase_user_id_unique;
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_supabase_user_id_key;
ALTER TABLE users DROP COLUMN IF EXISTS supabase_user_id;
