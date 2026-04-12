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
├── controllers/               # Endpoints HTTP e orquestração
├── config/                    # Configurações globais e variáveis de ambiente
├── middlewares/               # Auth, RBAC, Validação e Segurança
└── utils/                     # Helpers (Storage, Erros, etc)
```

### 2.2 Decisões Técnicas

| Decisão | Opção Escolhida | Justificativa |
|---|---|---|
| Banco de dados | PostgreSQL | Suporte nativo a JSON, PGVector para RAG |
| ORM | **Nenhum** (driver `pg` nativo) | Controle total, performance, ADR-0003 |
| Linguagem | TypeScript (strict) | Tipagem forte sem ORM exige interfaces sólidas |
| Arquitetura | Camadas (Controller → Service → Repository) | Separação clara de responsabilidades |
| Proteção Bot | API Key | Garante que apenas o robô de WhatsApp acesse endpoints de ingestão |

### 2.5 Middlewares Globais

A aplicação utiliza um pipeline de middlewares para garantir segurança e consistência:

1. **`errorHandler`**: Captura todas as exceções e as formata conforme os DTOs de erro, ocultando detalhes em produção.
2. **`authMiddleware`**: Valida o token JWT e popula o objeto `req.user`.
3. **`roleMiddleware`**: Bloqueia rotas específicas baseadas no papel (`LAWYER` / `CLIENT`).
4. **`apiKeyMiddleware`**: Valida a chave estática para integrações de backend-to-backend.
5. **`validationMiddleware`**: (Zod/Joi) Integração para validar o corpo e parâmetros das requisições.

### 2.6 Padrão de Controllers

Os controladores são implementados como classes, utilizando `RequestHandler` para garantir tipagem:

- **Responsabilidade**: Extrair dados da Request, validar permissões de propriedade (**Ownership**) e invocar o Service correspondente.
- **Injeção**: Repositórios são instanciados no construtor para permitir buscas rápidas de validação de acesso antes da chamada ao serviço.
- **Resposta**: Sempre utilizam códigos HTTP semânticos (200, 201, 204, 401, 403, 404).

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
        uuid advogadoId FK
        string titulo
        text descricao
        string statusAtual
        string numeroProcesso
        enum tipoCaso
        text ultimaNota
        timestamp dataUltimaMovimentacao
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