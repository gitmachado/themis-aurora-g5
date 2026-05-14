-- Create appointments table for managing lawyer schedules and deadlines.
-- Supports booking meetings, tracking deadlines, and hearings with automatic
-- conflict detection and reminder management for deadline notifications.

CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lawyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  client_id UUID REFERENCES users(id) ON DELETE SET NULL,
  process_id UUID REFERENCES legal_processes(id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(20) NOT NULL
    CONSTRAINT appointment_type_check CHECK (type IN ('MEETING', 'DEADLINE', 'HEARING', 'OTHER')),
  scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER,
  status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED'
    CONSTRAINT appointment_status_check CHECK (status IN ('SCHEDULED', 'COMPLETED', 'CANCELED')),
  reminded BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_appointments_lawyer_id ON appointments(lawyer_id);
CREATE INDEX idx_appointments_client_id ON appointments(client_id);
CREATE INDEX idx_appointments_process_id ON appointments(process_id);
CREATE INDEX idx_appointments_scheduled_at ON appointments(scheduled_at);
CREATE INDEX idx_appointments_type_status ON appointments(type, status);
CREATE INDEX idx_appointments_lawyer_scheduled ON appointments(lawyer_id, scheduled_at);
