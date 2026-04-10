# Arquitetura OmniConnect

## 1. Visão Geral

O OmniConnect segue uma arquitetura **monorepo** com três camadas principais:

```
omniconnect-aurora-g5/
├── mobile/          # App Flutter Único (Perfis Cliente e Advogado)
├── server/          # API Node.js + TypeScript (sem ORM)
└── documentation/   # PRD, specs, decisões, arquitetura
```

---

## 2. Backend — Arquitetura em Camadas

### 2.1 Estrutura de Pastas

```
server/src/
├── models/                    # Entidades do domínio (interfaces TS)
│   └── dtos/                  # Data Transfer Objects
├── repositories/interfaces/   # Contratos de acesso a dados
├── services/interfaces/       # Contratos de regras de negócio
├── controllers/               # Endpoints HTTP (futuro)
├── config/                    # Configuração do app (futuro)
├── middlewares/               # Auth, validação, etc (futuro)
└── utils/                     # Helpers compartilhados (futuro)
```

### 2.2 Decisões Técnicas

| Decisão | Opção Escolhida | Justificativa |
|---|---|---|
| Banco de dados | PostgreSQL | Suporte nativo a JSON, PGVector para RAG |
| ORM | **Nenhum** (driver `pg` nativo) | Controle total, performance, ADR-0003 |
| Linguagem | TypeScript (strict) | Tipagem forte sem ORM exige interfaces sólidas |
| Arquitetura | Camadas (Controller → Service → Repository) | Separação clara de responsabilidades |

### 2.3 Diagrama de Entidades (ER)

```mermaid
erDiagram
    User {
        uuid id PK
        string nome
        string whatsappNumber UK
        string cpf
        string email
        enum role "ADVOGADO | CLIENTE"
        string senhaHash
        string fcmToken
        timestamp createdAt
        timestamp updatedAt
    }

    Lead {
        uuid id PK
        string whatsappNumber UK
        string nome
        string cpf
        enum tipoCaso
        text descricaoCaso
        enum urgencia
        enum disponibilidadeContato
        enum status "PENDENTE | CONVERTIDO | DESCARTADO"
        uuid convertedUserId FK
        timestamp createdAt
    }

    Processo {
        uuid id PK
        uuid clienteId FK
        string titulo
        string statusAtual
        string numeroProcesso
        enum tipoCaso
        timestamp createdAt
        timestamp updatedAt
    }

    TimelineEvento {
        uuid id PK
        uuid processoId FK
        enum tipo
        text conteudo
        jsonb metadata
        uuid criadoPorId FK
        timestamp createdAt
    }

    Documento {
        uuid id PK
        uuid processoId FK
        string nomeArquivo
        string urlArquivo
        integer tamanhoBytes
        string tipoMime
        uuid enviadoPorId FK
        timestamp createdAt
    }

    Mensagem {
        uuid id PK
        uuid leadId FK
        uuid userId FK
        enum remetente "BOT | CLIENTE | ADVOGADO"
        text conteudo
        string whatsappMessageId
        timestamp createdAt
    }

    Notificacao {
        uuid id PK
        uuid userId FK
        enum tipo
        string titulo
        text corpo
        boolean lida
        jsonb dadosExtras
        timestamp createdAt
    }

    User ||--o{ Processo : "possui"
    User ||--o{ Notificacao : "recebe"
    User ||--o{ Mensagem : "envia/recebe (pós-conversão)"
    Lead ||--o{ Mensagem : "envia/recebe (pré-conversão)"
    Lead |o--o| User : "converte em"
    Processo ||--o{ TimelineEvento : "tem eventos"
    Processo ||--o{ Documento : "tem documentos"
    User ||--o{ TimelineEvento : "cria evento"
    User ||--o{ Documento : "envia documento"
```

### 2.4 Fluxo de Dados Principal

```mermaid
flowchart LR
    WA[WhatsApp] -->|Webhook| BOT[Bot IA/RAG]
    BOT -->|Cria| LEAD[Lead]
    BOT -->|Salva| MSG[Mensagem]
    APP[App Flutter] -->|Advogado: Converte| LEAD
    LEAD -->|Gera| USER[User/Cliente]
    APP -->|Advogado: Cria| PROC[Processo]
    APP -->|Advogado: Atualiza Status| TL[Timeline]
    TL -->|Dispara| NOTIF[Notificação FCM]
    NOTIF -->|Push| USER
    USER -->|Cliente: Upload| DOC[Documento]
    USER -->|Cliente: Leitura| MSG
```

---

## 3. Frontend Flutter — Arquitetura por Features

> Documentado na task G5-5. Estrutura baseada em features com navegação centralizada.

Diretório: `mobile/lib/`
- `app/` — configuração central (tema, rotas, shell)
- `features/` — features isoladas por domínio
- `shared/` — componentes e utilitários reutilizáveis

---

## 4. Decisões Adiadas

| Item | Motivo |
|---|---|
| Estratégia de cache/offline | Depende da definição de sincronização real-time |
| Tabela `embeddings_rag` | Será definida no ticket de IA (PGVector) |
| Autenticação JWT completa | Placeholders existem; implementação no ticket de API |
| WebSocket para tempo real | Será avaliado junto com a latência de 2s do PRD |