# Themis-ai

Módulo de IA do Themis — bot jurídico conversacional integrado ao WhatsApp.

## Visão Geral

O `Themis-ai` é o cérebro do atendimento automatizado do escritório. Recebe mensagens via WhatsApp Cloud API, processa com um grafo LangGraph e responde de forma contextual:

- **Triagem de leads**: coleta os 6 campos obrigatórios (nome, CPF, tipo de caso, descrição, urgência, disponibilidade) e cria o lead no backend
- **Consulta de processos**: clientes existentes consultam o status dos seus processos jurídicos
- **Base de conhecimento (RAG)**: responde dúvidas jurídicas com base em documentos indexados no pgvector
- **Handoff humano**: detecta quando o bot não pode ajudar e transfere para um advogado via notificação push

---

## Pré-requisitos

- **Node.js** 22+
- **Docker** e **Docker Compose** (para rodar com o stack completo)
- **PostgreSQL** 17+ com extensão `pgvector` (fornecida pela imagem `pgvector/pgvector:pg17`)
- Chaves de API:
  - `GOOGLE_API_KEY` — Google AI Studio (Gemini 1.5 Flash + text-embedding-004)
  - `WA_ACCESS_TOKEN` e `WA_PHONE_NUMBER_ID` — WhatsApp Cloud API (Meta)
  - `BOT_API_KEY` — chave de autenticação do backend Themis

---

## Setup

### 1. Instalar dependências

```bash
cd ai
npm install
```

### 2. Configurar variáveis de ambiente

```bash
cp .env.example .env
# Editar .env com suas chaves reais
```

### 3. Rodar com Docker Compose (recomendado)

```bash
# Na raiz do projeto
docker compose up -d
```

O serviço `Themis-ai` sobe na porta `3001` após o PostgreSQL e o backend estarem prontos.

### 4. Rodar localmente (desenvolvimento)

```bash
# Banco e backend devem estar rodando separadamente
npm run dev
```

### 5. Indexar documentos na base de conhecimento

```bash
npm run index:pdf -- knowledge/faq_geral.pdf
npm run index:pdf -- knowledge/jurisprudencia_trabalhista.pdf
# ... repetir para cada PDF em ai/knowledge/
```

---

## Arquitetura

### Grafo LangGraph

```
START → router → ┌─ triage  → sync → END
                 ├─ status  → sync → END
                 ├─ rag     → sync → END
                 │            └─ handoff → sync → END
                 ├─ handoff → sync → END
                 └─ sync    → END
```

### Nós do grafo

| Nó | Arquivo | Responsabilidade |
|---|---|---|
| `router` | `graph/nodes/router.ts` | Classifica intenção (LLM) e identifica tipo de usuário |
| `triage` | `graph/nodes/triage.ts` | Coleta sequencial dos 6 campos do lead com validação |
| `status` | `graph/nodes/status.ts` | Consulta e formata processos jurídicos do cliente |
| `rag` | `graph/nodes/rag.ts` | Busca vetorial no pgvector + resposta contextual (LLM) |
| `handoff` | `graph/nodes/handoff.ts` | Notifica advogado + pausa o grafo (`interrupt()`) |
| `sync` | `graph/nodes/sync.ts` | Sincroniza mensagens com o backend para o app Flutter |

### Persistência de estado

Cada conversa é identificada pelo `whatsappNumber` como `thread_id`. O `PostgresSaver` do LangGraph salva snapshots do `ThemisState` no banco, permitindo que o bot retome conversas após reinicializações.

---

## Scripts

| Script | Comando | Descrição |
|---|---|---|
| Desenvolvimento | `npm run dev` | Inicia o servidor com `ts-node` (sem build) |
| Build | `npm run build` | Compila TypeScript → `dist/` |
| Produção | `npm start` | Inicia o servidor compilado |
| Teste do grafo | `npm run test:graph "mensagem"` | Invoca o grafo localmente sem WhatsApp |
| Indexar PDF | `npm run index:pdf -- <arquivo.pdf>` | Indexa um PDF na base de conhecimento |
| Teste E2E lead | `npm run test:e2e-lead` | Simula fluxo completo de triagem de lead |
| Teste E2E RAG | `npm run test:e2e-rag` | Simula consulta de status, RAG e handoff |

---

## Variáveis de Ambiente

| Variável | Padrão | Descrição |
|---|---|---|
| `GOOGLE_API_KEY` | — | Chave da API Google AI Studio (obrigatória) |
| `GOOGLE_MODEL` | `gemini-1.5-flash` | Modelo LLM para inferência |
| `GOOGLE_EMBEDDING_MODEL` | `text-embedding-004` | Modelo de embeddings para RAG (768 dims) |
| `DATABASE_URL` | `postgresql://...` | String de conexão PostgreSQL com pgvector |
| `BACKEND_API_URL` | `http://localhost:3000` | URL base do backend Themis |
| `BOT_API_KEY` | — | API key para autenticação no backend (`x-api-key`) |
| `WA_VERIFY_TOKEN` | — | Token de verificação do webhook WhatsApp |
| `WA_ACCESS_TOKEN` | — | Token de acesso para envio de mensagens |
| `WA_PHONE_NUMBER_ID` | — | ID do número de telefone WhatsApp Business |
| `PORT` | `3001` | Porta do servidor Express |
| `NODE_ENV` | `development` | Ambiente de execução |

---

## Estrutura de Pastas

```
ai/
├── knowledge/               # PDFs da base de conhecimento para indexação
├── src/
│   ├── index.ts             # Ponto de entrada — servidor Express + inicialização
│   ├── config/
│   │   ├── checkpointer.ts  # PostgresSaver para persistência do estado LangGraph
│   │   └── prompts.ts       # Templates de prompts (sistema, triagem, RAG, router)
│   ├── graph/
│   │   ├── state.ts         # ThemisState — definição do estado compartilhado do grafo
│   │   ├── index.ts         # Montagem do grafo completo com arestas e compilação
│   │   └── nodes/
│   │       ├── router.ts    # Classificação de intenção e tipo de usuário
│   │       ├── triage.ts    # Coleta sequencial de dados do lead (6 etapas)
│   │       ├── status.ts    # Consulta de processos jurídicos
│   │       ├── rag.ts       # Busca vetorial + resposta contextual
│   │       ├── handoff.ts   # Transferência para advogado humano
│   │       └── sync.ts      # Sincronização de mensagens com o backend
│   ├── rag/
│   │   └── indexer.ts       # Pipeline de indexação: PDF → chunks → vetores → pgvector
│   ├── tests/
│   │   ├── e2e-lead.ts      # Teste E2E do fluxo de triagem de lead novo
│   │   └── e2e-status-rag-handoff.ts  # Teste E2E de status, RAG e handoff
│   ├── tools/
│   │   └── config-loader.ts # Carrega configuração do escritório via backend
│   ├── utils/
│   │   ├── validators.ts    # Validação de CPF, tipo de caso, urgência, disponibilidade
│   │   ├── service-hours.ts # Verificação de horário de atendimento (timezone São Paulo)
│   │   └── guardrails.ts    # Detecção de prompt injection
│   └── webhooks/
│       ├── whatsapp.ts      # Handlers GET/POST /webhook (WhatsApp Cloud API)
│       └── send-message.ts  # Envio de mensagens via WhatsApp com retry exponencial
├── .env.example             # Template de variáveis de ambiente
├── Dockerfile               # Build multi-stage (builder + runtime Node.js 22)
├── package.json
└── tsconfig.json
```
