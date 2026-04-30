ALTER TABLE users ADD COLUMN IF NOT EXISTS supabase_user_id TEXT;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS email TEXT;

UPDATE users
SET email = NULL
WHERE email = '';

ALTER TABLE IF EXISTS users
    DROP CONSTRAINT IF EXISTS users_supabase_user_id_key;

CREATE UNIQUE INDEX IF NOT EXISTS users_supabase_user_id_unique
    ON users(supabase_user_id)
    WHERE supabase_user_id IS NOT NULL;
