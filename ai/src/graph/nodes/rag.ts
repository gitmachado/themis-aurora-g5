import { ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings } from "@langchain/google-genai";
import { AIMessage } from "@langchain/core/messages";
import { PGVectorStore } from "@langchain/community/vectorstores/pgvector";
import { OmniStateType } from "../state.js";
import { SYSTEM_PROMPT, RAG_PROMPT } from "../../config/prompts.js";

const DATABASE_URL =
  process.env.DATABASE_URL ||
  "postgresql://postgres:postgres@localhost:5432/omniconnect";

// Indicadores determinísticos de que o LLM não encontrou resposta na base
const HANDOFF_INDICATORS = [
  "não tenho essa informação",
  "não está no contexto",
  "transferir para um advogado",
  "não posso responder",
  "fora do contexto",
];

function containsHandoffIndicator(text: string): boolean {
  const lower = text.toLowerCase();
  return HANDOFF_INDICATORS.some((indicator) => lower.includes(indicator));
}

export async function ragNode(
  state: OmniStateType
): Promise<Partial<OmniStateType>> {
  const { messages } = state;
  const query = String(messages.at(-1)?.content ?? "").trim();

  // 1. Inicializa embeddings e vector store
  const embeddings = new GoogleGenerativeAIEmbeddings({
    modelName: process.env.GOOGLE_EMBEDDING_MODEL || "text-embedding-004",
    apiKey: process.env.GOOGLE_API_KEY,
  });

  let vectorStore: PGVectorStore;
  try {
    vectorStore = await PGVectorStore.initialize(embeddings, {
      postgresConnectionOptions: { connectionString: DATABASE_URL },
      tableName: "knowledge_embeddings",
      columns: {
        contentColumnName: "content",
        metadataColumnName: "metadata",
        vectorColumnName: "embedding",
      },
    });
  } catch (err) {
    console.error("[RAG Node] Erro ao conectar ao pgvector:", err);
    return {
      currentNode: "handoff_node",
      needsHandoff: true,
      handoffReason: "Falha ao acessar a base de conhecimento",
      messages: [
        new AIMessage(
          "Não consegui acessar nossa base de conhecimento. Vou te conectar com um advogado."
        ),
      ],
    };
  }

  // 2. Busca os top 4 chunks mais relevantes
  let relevantDocs: Awaited<ReturnType<typeof vectorStore.similaritySearch>>;
  try {
    relevantDocs = await vectorStore.similaritySearch(query, 4);
  } catch (err) {
    console.error("[RAG Node] Erro na busca vetorial:", err);
    relevantDocs = [];
  } finally {
    await vectorStore.end();
  }

  // 3. Monta contexto a partir dos chunks recuperados
  const context =
    relevantDocs.length > 0
      ? relevantDocs.map((d) => d.pageContent).join("\n---\n")
      : "Nenhum documento relevante encontrado.";

  // 4. Gera resposta com prompt defensivo
  const model = new ChatGoogleGenerativeAI({
    modelName: process.env.GOOGLE_MODEL || "gemini-1.5-flash",
    apiKey: process.env.GOOGLE_API_KEY,
    temperature: 0,
  });

  const prompt = RAG_PROMPT.replace("{context}", context).replace("{query}", query);

  const response = await model.invoke([
    { role: "system", content: SYSTEM_PROMPT },
    { role: "user", content: prompt },
  ]);

  const responseText = String(response.content);

  // 5. Se sem chunks ou LLM indicou falta de informação → aciona handoff
  if (relevantDocs.length === 0 || containsHandoffIndicator(responseText)) {
    return {
      currentNode: "handoff_node",
      needsHandoff: true,
      handoffReason: "Pergunta fora da base de conhecimento",
      messages: [new AIMessage(responseText)],
    };
  }

  return {
    currentNode: "sync_node",
    needsHandoff: false,
    messages: [new AIMessage(responseText)],
  };
}
