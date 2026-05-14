-- Update constraints for Lawyer Actions
-- Adds DOCUMENT_REQUESTED and EVENT_SCHEDULED to timeline_events
-- Adds DOCUMENT_REQUESTED and NEW_NOTE to notifications

-- 1. Update timeline_events check constraint
ALTER TABLE timeline_events DROP CONSTRAINT IF EXISTS timeline_events_type_check;
ALTER TABLE timeline_events ADD CONSTRAINT timeline_events_type_check 
CHECK (type IN ('STATUS_UPDATE', 'LAWYER_NOTE', 'DOCUMENT_SENT', 'PROCESS_CREATED', 'DOCUMENT_REQUESTED', 'EVENT_SCHEDULED'));

-- 2. Update notifications check constraint
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_type_check 
CHECK (type IN ('NEW_LEAD', 'STATUS_CHANGED', 'DOCUMENT_SENT', 'HUMAN_SUPPORT', 'DOCUMENT_REQUESTED', 'NEW_NOTE', 'APPOINTMENT_SCHEDULED', 'APPOINTMENT_PENDING'));
