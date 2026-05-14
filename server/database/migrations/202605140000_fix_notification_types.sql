-- Migration: Fix notification type check constraint
-- Adds missing types used by the appointment and scheduling system:
--   APPOINTMENT_CHANGED, APPOINTMENT_PENDING, NEW_APPOINTMENT_AI, DEADLINE_WARNING
-- Previous constraint only had: NEW_LEAD, STATUS_CHANGED, DOCUMENT_SENT, HUMAN_SUPPORT,
--   DOCUMENT_REQUESTED, NEW_NOTE, APPOINTMENT_SCHEDULED, APPOINTMENT_PENDING

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
  CHECK (type IN (
    'NEW_LEAD',
    'STATUS_CHANGED',
    'DOCUMENT_SENT',
    'HUMAN_SUPPORT',
    'DOCUMENT_REQUESTED',
    'NEW_NOTE',
    'APPOINTMENT_SCHEDULED',
    'APPOINTMENT_CHANGED',
    'APPOINTMENT_PENDING',
    'NEW_APPOINTMENT_AI',
    'DEADLINE_WARNING'
  ));
