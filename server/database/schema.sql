-- OmniConnect Database Schema
-- Pattern: snake_case for tables/columns
-- Architecture: ADR-0003 (No ORM)

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Configurations
CREATE TABLE IF NOT EXISTS configurations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ai_tone_of_voice TEXT,
    service_hours_start TEXT, -- "09:00"
    service_hours_end TEXT,   -- "18:00"
    away_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    whatsapp_number TEXT UNIQUE NOT NULL,
    cpf TEXT UNIQUE,
    email TEXT UNIQUE,
    role TEXT NOT NULL CHECK (role IN ('LAWYER', 'CLIENT')),
    password_hash TEXT,
    fcm_token TEXT,
    notification_preferences JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Leads
CREATE TABLE IF NOT EXISTS leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    whatsapp_number TEXT NOT NULL,
    name TEXT,
    cpf TEXT,
    case_type TEXT CHECK (case_type IN ('Labor', 'Civil', 'Family', 'Criminal', 'SocialSecurity')),
    case_description TEXT,
    urgency TEXT CHECK (urgency IN ('High', 'Medium', 'Low')),
    contact_availability TEXT CHECK (contact_availability IN ('Morning', 'Afternoon', 'Evening')),
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_CONTACT', 'CONVERTED', 'DISCARDED')),
    converted_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    lawyer_notes TEXT,
    discard_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Legal Processes
CREATE TABLE IF NOT EXISTS legal_processes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES users(id),
    lawyer_id UUID REFERENCES users(id),
    title TEXT NOT NULL,
    description TEXT,
    current_status TEXT NOT NULL DEFAULT 'OPEN' CHECK (current_status IN ('OPEN', 'UNDER_ANALYSIS', 'AWAITING_DOCUMENT', 'COMPLETED', 'ARCHIVED')),
    process_number TEXT,
    case_type TEXT NOT NULL CHECK (case_type IN ('Labor', 'Civil', 'Family', 'Criminal', 'SocialSecurity')),
    last_note TEXT,
    last_movement_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Timeline Events
CREATE TABLE IF NOT EXISTS timeline_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    legal_process_id UUID NOT NULL REFERENCES legal_processes(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('STATUS_UPDATE', 'LAWYER_NOTE', 'DOCUMENT_SENT', 'PROCESS_CREATED')),
    content TEXT NOT NULL,
    previous_status TEXT,
    metadata JSONB DEFAULT '{}',
    created_by_id UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Documents
CREATE TABLE IF NOT EXISTS documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    legal_process_id UUID NOT NULL REFERENCES legal_processes(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    size_bytes BIGINT,
    mime_type TEXT,
    sent_by_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Messages
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id UUID REFERENCES leads(id) ON DELETE SET NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    sender TEXT NOT NULL CHECK (sender IN ('BOT', 'CLIENT', 'LAWYER')),
    content TEXT NOT NULL,
    whatsapp_message_id TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('NEW_LEAD', 'STATUS_CHANGED', 'DOCUMENT_SENT', 'HUMAN_SUPPORT')),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    extra_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Triggers for updated_at (Postgres doesn't update it automatically)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
DROP TRIGGER IF EXISTS update_configurations_updated_at ON configurations;
CREATE TRIGGER update_configurations_updated_at BEFORE UPDATE ON configurations FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_leads_updated_at ON leads;
CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON leads FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_legal_processes_updated_at ON legal_processes;
CREATE TRIGGER update_legal_processes_updated_at BEFORE UPDATE ON legal_processes FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_timeline_events_updated_at ON timeline_events;
CREATE TRIGGER update_timeline_events_updated_at BEFORE UPDATE ON timeline_events FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_documents_updated_at ON documents;
CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON documents FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_notifications_updated_at ON notifications;
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
