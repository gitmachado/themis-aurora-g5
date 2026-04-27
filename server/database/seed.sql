-- Seed Data for OmniConnect MVP

-- Insert initial configuration
INSERT INTO configurations (id, ai_tone_of_voice, service_hours_start, service_hours_end, away_message)
VALUES ('f5a2b3c4-d5e6-4f88-8912-0123456789ab', 'Profissional e acolhedor', '09:00', '18:00', 'Olá! No momento não estamos atendendo, mas deixe sua dúvida que responderemos em breve.')
ON CONFLICT (id) DO NOTHING;

-- Insert Lawyer (User)
INSERT INTO users (id, name, whatsapp_number, cpf, email, role, password_hash)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Dr. Thigs Advogado', '5511999999999', '12345678901', 'mauricio@adv.com.br', 'LAWYER', '$2b$12$EjP.Xm6.mK.Xm6.mK.Xm6.mK.Xm6.mK.Xm6.mK.Xm6.mK.Xm6')
ON CONFLICT (id) DO NOTHING;

-- Insert Client (User)
INSERT INTO users (id, name, whatsapp_number, cpf, email, role)
VALUES ('b1f9e8d7-c6b5-a4b3-92a1-0f9e8d7c6b5a', 'João Cliente Exemplo', '5511888888888', '98765432100', 'joao@cliente.com', 'CLIENT')
ON CONFLICT (id) DO NOTHING;

-- Insert Pending Lead
INSERT INTO leads (id, whatsapp_number, name, case_type, case_description, urgency, status)
VALUES ('c2e1d0c9-b8a7-a6b5-94c3-2d1e0f9a8b7c', '5511777777777', 'Maria Leads', 'Labor', 'Fui demitida sem justa causa e não recebi verbas.', 'High', 'PENDING')
ON CONFLICT (id) DO NOTHING;

-- Insert Converted Lead
INSERT INTO leads (id, whatsapp_number, name, case_type, status, converted_user_id)
VALUES ('d3f2e1d0-c9b8-a7b6-85d4-3e2f1e0d9c8b', '5511888888888', 'João Cliente Exemplo', 'Civil', 'CONVERTED', 'b1f9e8d7-c6b5-a4b3-92a1-0f9e8d7c6b5a')
ON CONFLICT (id) DO NOTHING;

-- Insert Legal Process
INSERT INTO legal_processes (id, client_id, lawyer_id, title, description, current_status, case_type, process_number)
VALUES ('e4d3c2b1-a0f9-9e8d-7c6b-5a4b3c2d1e0f', 'b1f9e8d7-c6b5-a4b3-92a1-0f9e8d7c6b5a', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Ação Indenizatória - João', 'Caso de danos morais por cobrança indevida.', 'OPEN', 'Civil', '1234567-89.2024.8.26.0000')
ON CONFLICT (id) DO NOTHING;

-- Insert Timeline Events
INSERT INTO timeline_events (legal_process_id, type, content, created_by_id)
VALUES ('e4d3c2b1-a0f9-9e8d-7c6b-5a4b3c2d1e0f', 'PROCESS_CREATED', 'Processo iniciado no sistema após conversão do lead.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');

-- Insert Notification
INSERT INTO notifications (user_id, type, title, body)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'NEW_LEAD', 'Novo Lead Recebido', 'Maria Leads enviou uma solicitação de contato via WhatsApp.');
