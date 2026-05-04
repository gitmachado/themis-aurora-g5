# 04 — Stack e Setup do Módulo de IA

## Decisão: Módulo Isolado Primeiro

O módulo de IA será desenvolvido como um **serviço independente** dentro do monorepo, na pasta `ai/`. Ele terá seu próprio `package.json`, Docker container e porta. Depois, será integrado via Docker Compose.

```
Themis-aurora-g5/
├── mobile/       # Flutter (já existe)
├── server/       # API Node.js (já existe)
├── ai/           # ← NOVO: Módulo de IA
│   ├── src/
│   │   ├── graph/          # LangGraph: nós, estado, arestas
│   │   ├── tools/          # Tools do agente (API calls)
│   │   ├── rag/            # Pipeline RAG (loader, splitter, store)
│   │   ├── webhooks/       # Receptor do WhatsApp webhook
│   │   ├── config/         # Variáveis de ambiente e setup
│   │   └── index.ts        # Entry point
│   ├── knowledge/          # PDFs para indexação
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile
│   └── .env
└── docker-compose.yml      # Adiciona serviço `ai`
```

---

## Stack Tecnológica

| Camada | Tecnologia | Justificativa |
|--------|-----------|---------------|
| Runtime | Node.js + TypeScript | Mesmo do backend, facilita manutenção |
| Orquestração | `@langchain/langgraph` | Fluxo estruturado com estado |
| LLM | `@langchain/openai` (GPT-4o-mini) | Custo-benefício para produção |
| Embeddings | `@langchain/openai` (text-embedding-3-small) | Melhor custo para RAG |
| Vector Store | `pgvector` (extensão do PostgreSQL existente) | Zero infra nova |
| Checkpointer | `@langchain/langgraph-checkpoint-postgres` | Memória persistida no PG |
| Validação | `zod` | Já usado no backend |
| HTTP Server | `express` | Receber webhooks do WhatsApp |
| WhatsApp | `axios` para Cloud API | Enviar mensagens de volta |

---

## Dependências (package.json)

```json
{
  "name": "Themis-ai",
  "dependencies": {
    "@langchain/core": "^0.3.x",
    "@langchain/langgraph": "^0.2.x",
    "@langchain/openai": "^0.3.x",
    "@langchain/langgraph-checkpoint-postgres": "^0.0.x",
    "@langchain/community": "^0.3.x",
    "pg": "^8.20.0",
    "pgvector": "^0.2.x",
    "express": "^5.2.x",
    "axios": "^1.7.x",
    "zod": "^4.3.x",
    "dotenv": "^17.x",
    "pdf-parse": "^1.1.x"
  },
  "devDependencies": {
    "typescript": "^6.x",
    "ts-node": "^10.x",
    "tsconfig-paths": "^4.x",
    "@types/express": "^5.x",
    "@types/node": "^25.x"
  }
}
```

---

## Variáveis de Ambiente (.env)

```bash
# LLM
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4o-mini
EMBEDDING_MODEL=text-embedding-3-small

# PostgreSQL (mesmo banco do backend)
DATABASE_URL=postgresql://user:pass@postgres:5432/Themis

# Backend API
BACKEND_API_URL=http://server:3000
BOT_API_KEY=chave-que-ja-existe-no-server

# WhatsApp Cloud API
WA_VERIFY_TOKEN=token-de-verificacao
WA_ACCESS_TOKEN=token-do-meta
WA_PHONE_NUMBER_ID=id-do-numero

# Servidor
PORT=3001
NODE_ENV=development
```

---

## Docker Compose (adição ao existente)

```yaml
  ai:
    build:
      context: ./ai
      dockerfile: Dockerfile
    container_name: Themis-ai
    depends_on:
      postgres:
        condition: service_healthy
      server:
        condition: service_started
    env_file:
      - ./ai/.env
    ports:
      - "3001:3001"
    volumes:
      - ./ai:/app
      - ai_node_modules:/app/node_modules
    command: sh -c "npm run dev"
```

---

## Como Rodar Localmente (Dia 1)

```bash
# 1. Criar a pasta
mkdir ai && cd ai

# 2. Inicializar
npm init -y

# 3. Instalar dependências
npm install @langchain/core @langchain/langgraph @langchain/openai express zod pg dotenv axios

# 4. Copiar .env.example e preencher
cp .env.example .env

# 5. Habilitar pgvector no banco (1 vez)
# Adicionar ao schema.sql:
# CREATE EXTENSION IF NOT EXISTS vector;

# 6. Rodar
npm run dev
```

---

## Teste Isolado (sem WhatsApp)

Para testar sem precisar do webhook, criar um script `test-graph.ts`:

```typescript
import { graph } from "./src/graph";

// Simula mensagem de um número novo
const result = await graph.invoke({
  whatsappNumber: "5511999999999",
  messages: [{ role: "user", content: "Olá, preciso de ajuda" }],
});

console.log(result.messages.at(-1)?.content);
```

Isso permite iterar no grafo sem depender do Meta/WhatsApp.
