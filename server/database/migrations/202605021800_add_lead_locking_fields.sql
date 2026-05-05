-- Add fields for lead locking and AI state
ALTER TABLE leads ADD COLUMN IF NOT EXISTS assigned_lawyer_id UUID REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS is_ai_paused BOOLEAN DEFAULT FALSE;
