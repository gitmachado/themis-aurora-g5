import { ChatOpenAI, OpenAIEmbeddings } from "@langchain/openai";
import { AIMessage } from "@langchain/core/messages";
import { MemoryVectorStore } from "langchain/vectorstores/memory";
import { OmniStateType } from "../state.js";
import { SYSTEM_PROMPT, RAG_PROMPT } from "../../config/prompts.js";

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

  // 1. Inicializa embeddings e vector store (MOCK IN MEMORY)
  const embeddings = new OpenAIEmbeddings({
    model: process.env.OPENAI_EMBEDDING_MODEL || "text-embedding-3-small",
    apiKey: process.env.OPENAI_API_KEY,
  });

  let vectorStore: MemoryVectorStore;
  try {
    vectorStore = await MemoryVectorStore.fromTexts(
      [
        "O escritório OmniConnect atende casos de direito civil, empresarial e trabalhista.",
        "Nosso horário de atendimento é de segunda a sexta, das 09:00 às 18:00.",
        "Para iniciar a análise de um processo trabalhista, precisamos do contrato de trabalho e rescisão.",
        "Honorários advocatícios padrão do escritório são 30% do êxito na causa trabalhista.",
        "Nosso escritório fica localizado na Avenida Paulista, 1000, São Paulo.",
      ],
      [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 }],
      embeddings
    );
  } catch (err) {
    console.error("[RAG Node] Erro ao instanciar MemoryVectorStore:", err);
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
  }

  // 3. Monta contexto a partir dos chunks recuperados
  const context =
    relevantDocs.length > 0
      ? relevantDocs.map((d) => d.pageContent).join("\n---\n")
      : "Nenhum documento relevante encontrado.";

  // 4. Gera resposta com prompt defensivo
  const model = new ChatOpenAI({
    model: process.env.OPENAI_MODEL || "gpt-4o-mini",
    apiKey: process.env.OPENAI_API_KEY,
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
