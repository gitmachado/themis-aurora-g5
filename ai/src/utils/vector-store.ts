/**
 * Singleton do PGVectorStore para evitar criação de nova conexão a cada request.
 * Em produção, múltiplos requests simultâneos poderiam esgotar o pool do PostgreSQL.
 */
import { PGVectorStore } from "@langchain/community/vectorstores/pgvector";
import { OpenAIEmbeddings } from "@langchain/openai";

const DATABASE_URL =
  process.env.DATABASE_URL ||
  "postgresql://postgres:postgres@localhost:5433/themis_db";

let instance: PGVectorStore | null = null;

/**
 * Retorna uma instância singleton do PGVectorStore.
 * Thread-safe: se chamado concorrentemente, a segunda chamada aguarda a primeira.
 */
export async function getVectorStore(): Promise<PGVectorStore> {
  if (instance) return instance;

  const embeddings = new OpenAIEmbeddings({
    model: process.env.OPENAI_EMBEDDING_MODEL || "text-embedding-3-small",
    apiKey: process.env.OPENAI_API_KEY,
  });

  instance = await PGVectorStore.initialize(embeddings, {
    postgresConnectionOptions: { connectionString: DATABASE_URL },
    tableName: "knowledge_embeddings",
    columns: {
      idColumnName: "id",
      vectorColumnName: "embedding",
      contentColumnName: "content",
      metadataColumnName: "metadata",
    },
  });

  return instance;
}

/**
 * Busca documentos relevantes para uma query na base de conhecimento.
 * Retorna string formatada com os chunks ou mensagem de fallback.
 */
export async function searchKnowledge(
  query: string,
  topK: number = 3
): Promise<string> {
  try {
    const store = await getVectorStore();
    const docs = await store.similaritySearch(query, topK);
    if (docs.length > 0) {
      return docs.map((d) => d.pageContent).join("\n---\n");
    }
    return "Nenhuma informação encontrada na base de conhecimento.";
  } catch (err) {
    console.error("[VectorStore] Erro na busca vetorial:", err);
    return "Nenhuma informação encontrada na base de conhecimento.";
  }
}
