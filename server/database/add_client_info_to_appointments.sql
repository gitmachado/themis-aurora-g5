-- Migration: Add client info to appointments table
-- Date: 2026-05-14
-- Purpose: Store client name and WhatsApp number for AI-created appointments

ALTER TABLE appointments
ADD COLUMN IF NOT EXISTS client_name VARCHAR(255) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS client_whatsapp_number VARCHAR(20) DEFAULT NULL;

-- Create index for faster lookups by client WhatsApp when loading leaddata
CREATE INDEX IF NOT EXISTS idx_appointments_client_whatsapp ON appointments(client_whatsapp_number);
