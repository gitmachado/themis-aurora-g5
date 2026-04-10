# Arquitetura Técnica e Stack

## Stack Tecnológica

| Camada | Tecnologia | Justificativa |
|---|---|---|
| **Frontend Mobile** | Flutter (Dart) | App único para iOS e Android, performance nativa |
| **Backend API** | Node.js + TypeScript | Ecossistema vasto, tipagem forte, async nativo |
| **Banco de Dados** | PostgreSQL | Robusto, suporte a JSON, PGVector para IA |
| **ORM** | **Nenhum** (driver `pg` nativo) | Controle total sobre queries, sem overhead |
| **IA/NLP** | LangChain + PGVector | RAG para respostas jurídicas contextualizadas |
| **Integração WhatsApp** | API WhatsApp Business | Chatbot automatizado |
| **Push Notifications** | Firebase Cloud Messaging (FCM) | Notificações em tempo real |

## Arquitetura Geral

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  WhatsApp    │────▶│   Bot IA     │────▶│              │
│  (Cliente)   │     │  (LangChain) │     │   Backend    │
└──────────────┘     └──────────────┘     │   Node.js    │
                                          │  TypeScript  │
┌──────────────┐                          │              │
│ App Flutter  │◀──────────────────────▶│              │
│ (Perfil Cli) │       REST API          │              │
└──────────────┘                          │              │
                                          │              │
┌──────────────┐                          │              │
│ App Flutter  │◀──────────────────────▶│              │
│ (Perfil Adv) │       REST API          └──────┬───────┘
└──────────────┘                                │
                                          ┌─────▼───────┐
        ┌──────────────┐                  │ PostgreSQL  │
        │     FCM      │◀────────────────│ + PGVector  │
        │  (Push)      │                  └─────────────┘
        └──────┬───────┘
               │
        Notificações para
        Cliente e Advogado
```

## Monorepo

```
omniconnect-aurora-g5/
├── mobile/              # App Flutter (Cliente + Advogado em 1 app)
├── server/              # API Node.js + TypeScript
│   └── src/
│       ├── models/      # Entidades e DTOs
│       ├── repositories/# Acesso a dados (interfaces)
│       ├── services/    # Regras de negócio (interfaces)
│       ├── controllers/ # Endpoints (futuro)
│       ├── config/      # Configurações
│       ├── middlewares/  # Auth, validação
│       └── utils/       # Helpers
└── documentation/       # PRD, specs, decisões, apresentação
```

## Backend — Arquitetura em Camadas

```
Controller (HTTP) → Service (Regras de Negócio) → Repository (SQL direto)
```

- **Controllers:** Recebem requests, validam input, delegam para services.
- **Services:** Orquestram lógica (ex: converter lead → criar user → gerar senha → notificar).
- **Repositories:** Executam queries SQL puras contra o PostgreSQL.
- **Sem ORM:** Decisão deliberada — controle total sobre as queries, sem magic, performance máxima.

## Decisões Técnicas Registradas

| # | Decisão | Motivo |
|---|---|---|
| ADR-0001 | Node.js + TypeScript + PostgreSQL como stack | Melhor fit para o time e os requisitos async |
| ADR-0003 | PostgreSQL **sem ORM** | Controle total, eliminação de overhead, queries otimizáveis |
| — | Enums como Union Types (não `enum` TS) | Zero overhead em runtime, apenas compilação |
| — | Nomes de domínio em PT-BR | DDD: linguagem ubíqua do domínio jurídico brasileiro |
| — | Branch pattern: `feat/G5-XX-descricao` | Rastreabilidade Linear ↔ Git |
| — | Commit pattern: `🌟feat: G5-XX description` | Histórico limpo com emojis + ticket |
