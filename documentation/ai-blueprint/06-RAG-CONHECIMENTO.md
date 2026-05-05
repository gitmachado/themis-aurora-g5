# 06 — RAG e Base de Conhecimento

## O que é RAG no nosso contexto?

O escritório possui documentos jurídicos (PDFs) com orientações internas, modelos de contrato, jurisprudências e regras de negócio. O bot precisa responder dúvidas dos clientes com base **nesses documentos**, sem inventar informações.

---

## Pipeline RAG

```
┌─────────────┐     ┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│  1. LOAD    │────▶│  2. SPLIT   │────▶│  3. EMBED    │────▶│  4. STORE    │
│  PDF/Docs   │     │  Chunks     │     │  Vetores     │     │  pgvector    │
└─────────────┘     └─────────────┘     └──────────────┘     └──────────────┘

                    Em tempo de QUERY:

┌─────────────┐     ┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│  5. QUERY   │────▶│  6. EMBED   │────▶│  7. SEARCH   │────▶│  8. GENERATE │
│  Pergunta   │     │  Vetor      │     │  Top-K docs  │     │  LLM+Contexto│
└─────────────┘     └─────────────┘     └──────────────┘     └──────────────┘
```

---

## Etapa 1-4: Indexação (rodada uma vez + quando advogado faz upload)

### Loader
```typescript
import { PDFLoader } from "@langchain/community/document_loaders/fs/pdf";

const loader = new PDFLoader("knowledge/jurisprudencia_trabalhista.pdf");
const docs = await loader.load();
```

### Splitter
```typescript
import { RecursiveCharacterTextSplitter } from "langchain/text_splitter";

const splitter = new RecursiveCharacterTextSplitter({
  chunkSize: 1000,     // ~250 tokens
  chunkOverlap: 200,   // sobreposição para contexto
});
const chunks = await splitter.splitDocuments(docs);
```

### Embeddings + Store
```typescript
import { OpenAIEmbeddings } from "@langchain/openai";
import { PGVectorStore } from "@langchain/community/vectorstores/pgvector";

const embeddings = new OpenAIEmbeddings({
  model: "text-embedding-3-small",
});

const vectorStore = await PGVectorStore.initialize(embeddings, {
  postgresConnectionOptions: { connectionString: DATABASE_URL },
  tableName: "knowledge_embeddings",
  columns: { contentColumnName: "content", metadataColumnName: "metadata", vectorColumnName: "embedding" },
});

await vectorStore.addDocuments(chunks);
```

---

## Schema SQL para Embeddings

Adicionar ao `schema.sql`:

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS knowledge_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    embedding vector(1536),   -- text-embedding-3-small = 1536 dims
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para busca rápida (HNSW é mais rápido que IVFFlat)
CREATE INDEX IF NOT EXISTS idx_knowledge_embedding_hnsw
ON knowledge_embeddings
USING hnsw (embedding vector_cosine_ops);
```

---

## Etapa 5-8: Query (em tempo real, a cada pergunta)

```typescript
// No rag_node do LangGraph:
async function ragNode(state: ThemisState) {
  const query = state.messages.at(-1)?.content;

  // Busca semântica — top 4 chunks mais relevantes
  const relevantDocs = await vectorStore.similaritySearch(query, 4);

  // Monta contexto
  const context = relevantDocs.map(d => d.pageContent).join("\n---\n");

  // Prompt defensivo
  const prompt = `
    Baseado EXCLUSIVAMENTE no contexto abaixo, responda a pergunta do cliente.
    Se a resposta NÃO estiver no contexto, diga que não tem essa informação
    e ofereça transferir para um advogado.

    CONTEXTO:
    ${context}

    PERGUNTA: ${query}
  `;

  const response = await llm.invoke(prompt);
  return { messages: [response] };
}
```

---

## Base de Conhecimento Inicial

Para o MVP, o escritório terá estes documentos na pasta `ai/knowledge/`:

| Arquivo | Conteúdo |
|---------|----------|
| `jurisprudencia_trabalhista.pdf` | Orientações sobre direito trabalhista |
| `regras_escritorio_honorarios.pdf` | Tabela de valores e regras de cobrança |
| `modelos_contrato_civel.pdf` | Templates de contratos cíveis |
| `documentos_necessarios.pdf` | Lista de documentos por tipo de caso |
| `faq_geral.pdf` | Perguntas frequentes dos clientes |

---

## Tela "Gestão de IA" no Flutter (já existe!)

A tela `LawyerAIManagerScreen` já tem:
- Toggle de ativar/desativar bot
- Campo de "Tom de Voz" editável
- Slider de "Criatividade (Temperatura)"
- Seção "Base de Conhecimento" com upload de PDF e status (Ativo/Analisando)

O backend do upload de PDF na base de conhecimento será uma **nova rota** no módulo de IA:
- `POST /ai/knowledge/upload` → recebe PDF, roda pipeline de indexação
- `GET /ai/knowledge` → lista documentos indexados
- `DELETE /ai/knowledge/:id` → remove documento e seus embeddings

---

## Métricas do RAG

Para monitoramento via LangSmith (futuro):
- **Relevância**: Score de similaridade dos chunks recuperados
- **Fidelidade**: A resposta se baseia nos chunks ou alucinou?
- **Latência**: Tempo total da query (embed + search + generate)
