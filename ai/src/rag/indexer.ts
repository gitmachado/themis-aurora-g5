import { PDFLoader } from "@langchain/community/document_loaders/fs/pdf";
import { RecursiveCharacterTextSplitter } from "@langchain/textsplitters";
import { OpenAIEmbeddings } from "@langchain/openai";
import { PGVectorStore } from "@langchain/community/vectorstores/pgvector";
import path from "path";

const DATABASE_URL =
  process.env.DATABASE_URL ||
  "postgresql://postgres:postgres@localhost:5433/themis_db";

async function indexPDF(filePath: string): Promise<void> {
  console.log(`\n[indexer] Iniciando indexação: ${filePath}`);

  // Etapa 1 — Load: carrega o PDF página por página
  const loader = new PDFLoader(filePath);
  const docs = await loader.load();
  console.log(`[indexer] Carregado: ${docs.length} página(s)`);

  // Etapa 2 — Split: divide em chunks com overlap para não perder contexto
  const splitter = new RecursiveCharacterTextSplitter({
    chunkSize: 1000,
    chunkOverlap: 200,
  });
  const chunks = await splitter.splitDocuments(docs);
  console.log(`[indexer] Dividido em: ${chunks.length} chunk(s)`);

  // Etapa 3 — Enriquece metadata por chunk
  const filename = path.basename(filePath);
  const indexedAt = new Date().toISOString();
  const enrichedChunks = chunks.map((chunk, idx) => ({
    ...chunk,
    metadata: {
      ...chunk.metadata,
      filename,
      pageNumber: (chunk.metadata as any)?.loc?.pageNumber ?? 0,
      indexedAt,
      chunkIndex: idx,
    },
  }));

  // Etapa 4 — Embed + Store: gera vetores e salva no pgvector
  const embeddings = new OpenAIEmbeddings({
    model: process.env.OPENAI_EMBEDDING_MODEL || "text-embedding-3-small",
    apiKey: process.env.OPENAI_API_KEY,
  });

  const vectorStore = await PGVectorStore.initialize(embeddings, {
    postgresConnectionOptions: { connectionString: DATABASE_URL },
    tableName: "knowledge_embeddings",
    columns: {
      contentColumnName: "content",
      metadataColumnName: "metadata",
      vectorColumnName: "embedding",
    },
  });

  try {
    await vectorStore.addDocuments(enrichedChunks);
    console.log(
      `[indexer] ✅ ${enrichedChunks.length} chunk(s) indexado(s) com sucesso!`
    );
    console.log(`[indexer] Arquivo: ${filename} | Data: ${indexedAt}`);
  } finally {
    await vectorStore.end();
  }
}

// CLI — recebe o caminho do PDF como argumento
const filePath = process.argv[2];

if (!filePath) {
  console.error("Uso: npm run index:pdf -- <caminho-do-pdf>");
  console.error("Exemplo: npm run index:pdf -- knowledge/faq_geral.pdf");
  process.exit(1);
}

indexPDF(path.resolve(filePath)).catch((err) => {
  console.error("[indexer] Erro:", err.message);
  process.exit(1);
});
