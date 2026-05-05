-- Sinaliza usuários que entraram com senha temporária e devem trocar no
-- primeiro login (advogados cadastrados pelo chefe via /team).

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT FALSE;
