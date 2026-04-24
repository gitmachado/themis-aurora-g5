# 01 — Visão Geral do Sistema

## O que é o Themis?

Plataforma de **gestão jurídica inteligente** para escritórios de advocacia. O cliente inicia contato via **WhatsApp com um chatbot de IA**, e o ciclo de vida do caso é acompanhado por um **app Flutter único** com perfis distintos (Cliente e Advogado).

## O que já temos pronto

### ✅ Backend (Node.js + TypeScript)
- API REST completa com autenticação JWT e RBAC (LAWYER/CLIENT)
- Endpoints: Auth, Leads, Processos, Timeline, Documentos, Mensagens, Notificações
- Banco PostgreSQL com schema completo (8 tabelas)
- Middleware de API Key para integrações bot-to-backend
- Swagger/OpenAPI documentado
- Docker Compose funcional (server + postgres)
- Endpoint `POST /leads` (protegido por API Key) — **este é o endpoint que o bot vai usar para criar leads**
- Endpoint `POST /messages/sync` (protegido por API Key) — **este é o endpoint que o bot vai usar para sincronizar mensagens**

### ✅ Frontend Flutter
- **25 telas** implementadas cobrindo ambos os perfis
- Tela de **Gestão de IA (RAG)** já existe no painel do advogado (`LawyerAIManagerScreen`)
- Tela de **Chat Mirror** no perfil do cliente (espelho read-only das conversas com o bot)
- Tela de **Handoff** para o advogado (com banner "IA solicitou intervenção")
- Tela de **Lead Detail** mostrando dados "Capturados pelo Bot"
- Card "Dúvida rápida com a IA?" na home do cliente
- Filtros de "Aguardando Handoff" na lista de chats do advogado

### ✅ Integração Frontend ↔ Backend
- Em progresso pelo Thiago (não é responsabilidade do time de IA)

## O que falta: O Módulo de IA 🧠

```
┌────────────────────────────────────────────────────┐
│                    WhatsApp                         │
│              (Cloud API / Webhook)                  │
└───────────────────┬────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────────────────┐
│           🤖 MÓDULO DE IA (vocês!)                 │
│                                                    │
│  • Receber mensagem via Webhook WhatsApp           │
│  • Identificar se é lead novo ou cliente existente │
│  • Executar fluxo de triagem (coletar 6 campos)    │
│  • Consultar status de processos via API           │
│  • Responder dúvidas jurídicas via RAG             │
│  • Detectar necessidade de handoff humano          │
│  • Sincronizar todas as mensagens com o backend    │
└───────────────────┬────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────────────────┐
│           Backend API (já existe)                   │
│  POST /leads — criar lead                          │
│  POST /messages/sync — sincronizar mensagens       │
│  GET /processes/my — consultar processos           │
│  GET /messages/:whatsappNumber — histórico         │
└────────────────────────────────────────────────────┘
```

## O que o bot precisa fazer (resumo)

| Capacidade | Descrição |
|------------|-----------|
| **Triagem de Leads** | Coletar Nome, CPF, Tipo de Caso, Descrição, Urgência e Disponibilidade de novos contatos |
| **Consulta de Status** | Identificar cliente pelo telefone e retornar o status atualizado dos processos |
| **RAG Jurídico** | Responder dúvidas com base em PDFs/docs indexados na base de conhecimento do escritório |
| **Handoff Humano** | Detectar palavras-chave ou falha da IA e transferir para o advogado |
| **Sincronia** | Toda mensagem trocada é salva no backend para espelhamento no app Flutter |

## Tabelas do banco que o bot interage

| Tabela | Interação |
|--------|-----------|
| `leads` | Cria novos leads (via API Key) |
| `messages` | Sincroniza cada mensagem trocada (via API Key) |
| `users` | Consulta se o telefone já pertence a um cliente |
| `legal_processes` | Consulta status dos processos de um cliente |
| `configurations` | Lê tom de voz e horário de atendimento |
| `notifications` | Dispara notificações para advogados (via API) |

## Tabela `configurations` — já existe no banco

```sql
configurations (
  ai_tone_of_voice TEXT,         -- "Profissional e acolhedor"
  service_hours_start TEXT,      -- "09:00"
  service_hours_end TEXT,        -- "18:00"
  away_message TEXT              -- Mensagem fora do horário
)
```

> **O backend já foi pensado para o bot.** Os endpoints de API Key e a tabela de configurações provam isso. O módulo de IA é um consumidor first-class da API.
