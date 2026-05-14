SET client_encoding = 'UTF8';

-- =============================================================================
-- Seed completo do Themis (idempotente — limpa tudo e popula com dados de teste)
-- Senha de TODAS as contas: Themis@123456
-- Contas:
--   - themis@gmail.com   → LAWYER_ADMIN (chefe do escritório)
--   - ana@themis.com.br  → LAWYER (advogada da equipe — subordinada ao chefe)
--   - cliente@gmail.com  → CLIENT
-- =============================================================================

-- Limpa tudo (ordem da CASCADE não importa). Mantém schema_migrations.
TRUNCATE TABLE
  knowledge_embeddings,
  notifications,
  messages,
  documents,
  timeline_events,
  legal_processes,
  leads,
  users,
  configurations
RESTART IDENTITY CASCADE;

-- -----------------------------------------------------------------------------
-- 1. Configuração da IA / horário de atendimento
-- -----------------------------------------------------------------------------
INSERT INTO configurations (id, ai_tone_of_voice, service_hours_start, service_hours_end, away_message)
VALUES (
  'f5a2b3c4-d5e6-4f88-8912-0123456789ab',
  'Profissional e acolhedor',
  '09:00',
  '18:00',
  'Olá! No momento não estamos atendendo. Deixe sua dúvida que retornaremos em breve.'
);

-- -----------------------------------------------------------------------------
-- 2. Usuários
-- -----------------------------------------------------------------------------
-- Hash bcrypt de "Themis@123456":
--   $2b$10$dx3Gm9Ftqkr6crSt5MFoIO.fgZ/RoQLy5Ay20YAaawzhdl.l.7qsq

-- Admin / chefe do escritório
INSERT INTO users (
  id, name, whatsapp_number, cpf, email, role, password_hash,
  notification_preferences, team_permissions, must_change_password
)
VALUES (
  '11111111-1111-4111-8111-111111111111',
  'Themis Admin',
  '5511999990001',
  '00000000001',
  'themis@gmail.com',
  'LAWYER_ADMIN',
  '$2b$10$dx3Gm9Ftqkr6crSt5MFoIO.fgZ/RoQLy5Ay20YAaawzhdl.l.7qsq',
  '{"push": true, "whatsapp": true, "leads": true, "processUpdates": true, "documents": true}'::jsonb,
  '{}'::jsonb,
  FALSE
);

-- Advogada da equipe (subordinada ao admin acima)
INSERT INTO users (
  id, name, whatsapp_number, cpf, email, role, password_hash,
  notification_preferences, team_permissions,
  lawyer_admin_id, oab_number, specialty, must_change_password
)
VALUES (
  '22222222-2222-4222-8222-222222222222',
  'Dra. Ana Souza',
  '5511999990002',
  '00000000002',
  'ana@themis.com.br',
  'LAWYER',
  '$2b$10$dx3Gm9Ftqkr6crSt5MFoIO.fgZ/RoQLy5Ay20YAaawzhdl.l.7qsq',
  '{"push": true, "whatsapp": true, "leads": true, "processUpdates": true, "documents": true}'::jsonb,
  '{"viewAllClients": false, "convertLeads": true, "manageDocuments": true, "receiveSupportNotifications": true}'::jsonb,
  '11111111-1111-4111-8111-111111111111',
  'SP123456',
  'Civil',
  FALSE
);

-- Cliente
INSERT INTO users (
  id, name, whatsapp_number, cpf, email, role, password_hash,
  notification_preferences
)
VALUES (
  '33333333-3333-4333-8333-333333333333',
  'João Cliente',
  '5511888880001',
  '11122233344',
  'cliente@gmail.com',
  'CLIENT',
  '$2b$10$dx3Gm9Ftqkr6crSt5MFoIO.fgZ/RoQLy5Ay20YAaawzhdl.l.7qsq',
  '{"push": true, "whatsapp": true, "processUpdates": true, "documents": true}'::jsonb
);

-- -----------------------------------------------------------------------------
-- 3. Leads (popular a aba Pendentes / Arquivados)
-- -----------------------------------------------------------------------------
-- PENDING — apareceu sozinho, ninguém atendeu ainda
INSERT INTO leads (id, whatsapp_number, name, email, cpf, case_type, case_description, urgency, contact_availability, status)
VALUES (
  '44444444-4444-4444-8444-444444444444',
  '5511777770001',
  'Maria Trabalhadora',
  'maria.lead@example.com',
  '55566677788',
  'Labor',
  'Fui demitida sem justa causa e não recebi minhas verbas rescisórias.',
  'High',
  'Morning',
  'PENDING'
);

-- IN_CONTACT — em atendimento humano com a Dra. Ana
INSERT INTO leads (id, whatsapp_number, name, email, case_type, case_description, urgency, status, assigned_lawyer_id, is_ai_paused)
VALUES (
  '55555555-5555-4555-8555-555555555555',
  '5511777770002',
  'Pedro Investidor',
  'pedro.lead@example.com',
  'Civil',
  'Sofri uma cobrança indevida e quero entrar com ação.',
  'Medium',
  'IN_CONTACT',
  '22222222-2222-4222-8222-222222222222',
  TRUE
);

-- CONVERTED — virou o cliente João
INSERT INTO leads (id, whatsapp_number, name, email, case_type, status, converted_user_id)
VALUES (
  '66666666-6666-4666-8666-666666666666',
  '5511888880001',
  'João Cliente',
  'cliente@gmail.com',
  'Family',
  'CONVERTED',
  '33333333-3333-4333-8333-333333333333'
);

-- DISCARDED — descartado para popular a aba "Arquivados"
INSERT INTO leads (id, whatsapp_number, name, case_type, case_description, urgency, status, discard_reason)
VALUES (
  '77777777-7777-4777-8777-777777777777',
  '5511777770003',
  'Bruno Curioso',
  'Criminal',
  'Apenas dúvida sobre legislação geral.',
  'Low',
  'DISCARDED',
  'Sem demanda jurídica concreta — apenas dúvida.'
);

-- -----------------------------------------------------------------------------
-- 4. Processo legal do cliente (atribuído ao admin)
-- -----------------------------------------------------------------------------
INSERT INTO legal_processes (
  id, client_id, lawyer_id, title, description, current_status, process_number, case_type,
  last_note, last_movement_date
)
VALUES (
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
  '33333333-3333-4333-8333-333333333333',
  '11111111-1111-4111-8111-111111111111',
  'Ação de Divórcio Consensual',
  'Divórcio consensual com partilha de bens e guarda compartilhada de filhos menores.',
  'UNDER_ANALYSIS',
  '1234567-89.2026.8.26.0100',
  'Family',
  'Aguardando documentação complementar do cliente.',
  NOW() - INTERVAL '2 days'
);

-- Segundo processo (atribuído à Dra. Ana, pra equipe não ficar sem stats)
INSERT INTO legal_processes (
  id, client_id, lawyer_id, title, description, current_status, case_type,
  last_note, last_movement_date
)
VALUES (
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2',
  '33333333-3333-4333-8333-333333333333',
  '22222222-2222-4222-8222-222222222222',
  'Acordo Trabalhista',
  'Acordo extrajudicial referente a verbas rescisórias.',
  'OPEN',
  'Labor',
  'Análise inicial dos documentos.',
  NOW() - INTERVAL '5 days'
);

-- -----------------------------------------------------------------------------
-- 5. Timeline events do processo principal
-- -----------------------------------------------------------------------------
INSERT INTO timeline_events (legal_process_id, type, content, created_by_id, created_at)
VALUES
  (
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
    'PROCESS_CREATED',
    'Processo aberto após conversão do lead.',
    '11111111-1111-4111-8111-111111111111',
    NOW() - INTERVAL '10 days'
  ),
  (
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
    'LAWYER_NOTE',
    'Conversa inicial com o cliente. Houve alinhamento sobre partilha amigável.',
    '11111111-1111-4111-8111-111111111111',
    NOW() - INTERVAL '8 days'
  ),
  (
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
    'STATUS_UPDATE',
    'Status alterado para Em análise.',
    '11111111-1111-4111-8111-111111111111',
    NOW() - INTERVAL '5 days'
  ),
  (
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
    'DOCUMENT_REQUESTED',
    'Documento solicitado: certidão de casamento atualizada.',
    '11111111-1111-4111-8111-111111111111',
    NOW() - INTERVAL '3 days'
  ),
  (
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
    'EVENT_SCHEDULED',
    'Audiência de conciliação marcada para a próxima semana.',
    '11111111-1111-4111-8111-111111111111',
    NOW() - INTERVAL '2 days'
  );

-- Timeline do segundo processo (Dra. Ana)
INSERT INTO timeline_events (legal_process_id, type, content, created_by_id, created_at)
VALUES (
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2',
    'PROCESS_CREATED',
    'Processo aberto pela Dra. Ana Souza.',
    '22222222-2222-4222-8222-222222222222',
    NOW() - INTERVAL '5 days'
);

-- -----------------------------------------------------------------------------
-- 6. Mensagens (chat list / handoff)
-- -----------------------------------------------------------------------------
-- Conversa do lead pendente (Maria) com o bot — chat list do advogado
INSERT INTO messages (lead_id, whatsapp_number, sender, content, created_at)
VALUES
  ('44444444-4444-4444-8444-444444444444', '5511777770001', 'CLIENT', 'Olá, fui demitida sem justa causa.', NOW() - INTERVAL '1 hour'),
  ('44444444-4444-4444-8444-444444444444', '5511777770001', 'BOT',    'Olá Maria! Posso te ajudar. Você guardou seus comprovantes?', NOW() - INTERVAL '1 hour' + INTERVAL '1 minute'),
  ('44444444-4444-4444-8444-444444444444', '5511777770001', 'CLIENT', 'Sim, tenho holerites e CTPS digital.', NOW() - INTERVAL '50 minutes'),
  ('44444444-4444-4444-8444-444444444444', '5511777770001', 'BOT',    'Perfeito. Vou conectar você com um advogado especializado.', NOW() - INTERVAL '49 minutes');

-- Conversa do lead em atendimento (Pedro) — IA pausada, advogada conduz
INSERT INTO messages (lead_id, whatsapp_number, sender, content, created_at)
VALUES
  ('55555555-5555-4555-8555-555555555555', '5511777770002', 'CLIENT', 'Boa tarde, fui cobrado em duplicidade.', NOW() - INTERVAL '3 hours'),
  ('55555555-5555-4555-8555-555555555555', '5511777770002', 'LAWYER', 'Boa tarde Pedro! Aqui é a Dra. Ana. Pode me enviar o comprovante?', NOW() - INTERVAL '2 hours 50 minutes');

-- Conversa do cliente João com o bot
INSERT INTO messages (user_id, whatsapp_number, sender, content, created_at)
VALUES
  ('33333333-3333-4333-8333-333333333333', '5511888880001', 'CLIENT', 'Tem novidade no processo?', NOW() - INTERVAL '6 hours'),
  ('33333333-3333-4333-8333-333333333333', '5511888880001', 'BOT',    'Olá João! O status atual é "Em análise". Avisaremos quando houver movimento.', NOW() - INTERVAL '5 hours 59 minutes');

-- -----------------------------------------------------------------------------
-- 7. Notificações
-- -----------------------------------------------------------------------------
-- Para o admin
INSERT INTO notifications (user_id, type, title, body, is_read, created_at, extra_data)
VALUES
  ('11111111-1111-4111-8111-111111111111', 'NEW_LEAD',       'Novo lead recebido',     'Maria Trabalhadora enviou uma solicitação via WhatsApp.', FALSE, NOW() - INTERVAL '50 minutes', NULL),
  ('11111111-1111-4111-8111-111111111111', 'HUMAN_SUPPORT',  'Atendimento humano',     'Pedro Investidor pediu para falar com um advogado.',      FALSE, NOW() - INTERVAL '3 hours', '{"whatsappNumber": "5511999999999", "name": "Pedro Investidor"}'),
  ('11111111-1111-4111-8111-111111111111', 'NEW_NOTE',       'Nova nota no processo',  'Você adicionou uma nota em "Ação de Divórcio Consensual".', TRUE,  NOW() - INTERVAL '1 day', NULL);

-- Para a Dra. Ana
INSERT INTO notifications (user_id, type, title, body, is_read, created_at)
VALUES
  ('22222222-2222-4222-8222-222222222222', 'NEW_LEAD', 'Lead atribuído', 'O lead de Pedro Investidor foi atribuído a você.', FALSE, NOW() - INTERVAL '3 hours');

-- Para o cliente João
INSERT INTO notifications (user_id, type, title, body, is_read, created_at)
VALUES
  ('33333333-3333-4333-8333-333333333333', 'STATUS_CHANGED',     'Processo em análise',    'Seu processo "Ação de Divórcio Consensual" agora está em análise.', FALSE, NOW() - INTERVAL '5 days'),
  ('33333333-3333-4333-8333-333333333333', 'DOCUMENT_REQUESTED', 'Documento solicitado',   'Por favor envie a certidão de casamento atualizada.',                FALSE, NOW() - INTERVAL '3 days');
