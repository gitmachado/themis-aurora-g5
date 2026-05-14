-- Migration: Add appointment approval workflow
-- Adds columns to track AI-created appointments and approval status
-- Creates new table for reschedule suggestions

-- 1. Update appointments table constraint to include PENDING_APPROVAL status
ALTER TABLE appointments DROP CONSTRAINT IF EXISTS appointments_status_check;
ALTER TABLE appointments ADD CONSTRAINT appointments_status_check
  CHECK (status IN ('SCHEDULED', 'COMPLETED', 'CANCELED', 'PENDING_APPROVAL'));

-- 2. Add new columns to appointments table for AI approval workflow
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS created_by_ai BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS ai_created_at TIMESTAMPTZ;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS approved_by_lawyer_id UUID REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS ai_original_data JSONB;

-- 3. Create reschedule suggestions table
CREATE TABLE IF NOT EXISTS ai_reschedule_suggestions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
    lawyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    instruction TEXT NOT NULL,
    suggested_datetime TIMESTAMPTZ,
    suggested_title VARCHAR(255),
    suggested_description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'SUPERSEDED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_appointments_pending
  ON appointments(lawyer_id, status)
  WHERE status = 'PENDING_APPROVAL';

CREATE INDEX IF NOT EXISTS idx_appointments_created_by_ai
  ON appointments(lawyer_id, created_by_ai)
  WHERE created_by_ai = TRUE;

CREATE INDEX IF NOT EXISTS idx_reschedule_suggestions_pending
  ON ai_reschedule_suggestions(appointment_id, status);

CREATE INDEX IF NOT EXISTS idx_reschedule_suggestions_lawyer
  ON ai_reschedule_suggestions(lawyer_id, status);

-- 5. Apply update trigger to reschedule_suggestions
DROP TRIGGER IF EXISTS update_ai_reschedule_suggestions_updated_at ON ai_reschedule_suggestions;
CREATE TRIGGER update_ai_reschedule_suggestions_updated_at
  BEFORE UPDATE ON ai_reschedule_suggestions
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- 6. Add security trigger to prevent AI from creating SCHEDULED appointments directly
CREATE OR REPLACE FUNCTION prevent_ai_direct_scheduling()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_by_ai = TRUE AND NEW.status != 'PENDING_APPROVAL' THEN
        RAISE EXCEPTION 'AI can only create appointments with PENDING_APPROVAL status';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_ai_appointment_status ON appointments;
CREATE TRIGGER check_ai_appointment_status
  BEFORE INSERT ON appointments
  FOR EACH ROW EXECUTE PROCEDURE prevent_ai_direct_scheduling();
