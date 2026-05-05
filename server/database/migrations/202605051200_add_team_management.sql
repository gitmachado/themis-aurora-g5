-- Team management: introduce LAWYER_ADMIN role, per-lawyer permissions and admin link.

ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check
  CHECK (role IN ('LAWYER', 'CLIENT', 'LAWYER_ADMIN'));

ALTER TABLE users ADD COLUMN IF NOT EXISTS team_permissions JSONB NOT NULL DEFAULT '{}'::jsonb;
ALTER TABLE users ADD COLUMN IF NOT EXISTS lawyer_admin_id UUID REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS oab_number TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS specialty TEXT;

CREATE INDEX IF NOT EXISTS idx_users_lawyer_admin_id ON users(lawyer_admin_id);

-- Promove o advogado seed (Dr. Maurício) a chefe do escritório.
UPDATE users
SET role = 'LAWYER_ADMIN'
WHERE id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
