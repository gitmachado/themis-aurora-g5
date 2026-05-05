-- Adicionando mais eventos para João Cliente Exemplo
-- Process ID: e4d3c2b1-a0f9-9e8d-7c6b-5a4b3c2d1e0f
-- Lawyer ID: a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11

-- Eventos de Maio 2026
INSERT INTO timeline_events (legal_process_id, type, content, created_by_id, created_at)
VALUES 
('e4d3c2b1-a0f9-9e8d-7c6b-5a4b3c2d1e0f', 'STATUS_UPDATE', 'O status do processo foi alterado para: EM ANALISE.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-05-04 14:30:00'),
('e4d3c2b1-a0f9-9e8d-7c6b-5a4b3c2d1e0f', 'LAWYER_NOTE', 'Olá João, acabo de revisar sua petição e anexei os documentos necessários.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-05-03 10:00:00');

-- Eventos de Abril 2026
INSERT INTO timeline_events (legal_process_id, type, content, created_by_id, created_at)
VALUES 
('e4d3c2b1-a0f9-9e8d-7c6b-5a4b3c2d1e0f', 'DOCUMENT_SENT', 'Petição inicial enviada ao tribunal.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-04-15 09:15:00'),
('e4d3c2b1-a0f9-9e8d-7c6b-5a4b3c2d1e0f', 'STATUS_UPDATE', 'Documentação validada pela secretaria.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-04-10 16:45:00');

-- Eventos de Março 2026
INSERT INTO timeline_events (legal_process_id, type, content, created_by_id, created_at)
VALUES 
('e4d3c2b1-a0f9-9e8d-7c6b-5a4b3c2d1e0f', 'LAWYER_NOTE', 'Aguardando o cliente enviar o comprovante de residência.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-20 11:00:00'),
('e4d3c2b1-a0f9-9e8d-7c6b-5a4b3c2d1e0f', 'DOCUMENT_SENT', 'Procuração assinada recebida.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-05 14:00:00');
