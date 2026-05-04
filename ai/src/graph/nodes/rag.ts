import { ChatOpenAI, OpenAIEmbeddings } from "@langchain/openai";
import { AIMessage } from "@langchain/core/messages";
import { PGVectorStore } from "@langchain/community/vectorstores/pgvector";
import { OmniStateType } from "../state.js";
import { SYSTEM_PROMPT, RAG_PROMPT } from "../../config/prompts.js";

const DATABASE_URL = process.env.DATABASE_URL || "postgresql://postgres:postgres@localhost:5433/omniconnect_db";

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
  const lastMessage = messages.at(-1);
  const query = String(lastMessage?.content ?? "").trim();

  // 0. Detecção de "Intenção de Dúvida" ou Aceite de Ajuda sem a pergunta de fato
  const acceptanceKeywords = ["pode", "sim", "claro", "com certeza", "ok", "quero", "tenho uma dúvida", "tenho uma duvida"];
  const queryLower = query.toLowerCase().replace(/[!.?]/g, "").trim();
  
  // Só interceptamos se for uma mensagem MUITO curta (afirmação pura) ou palavras-chave isoladas.
  // Se tiver mais de 20 caracteres e contiver uma afirmação, provavelmente já é a dúvida vindo junto.
  if (queryLower.length < 25 && (acceptanceKeywords.includes(queryLower) || acceptanceKeywords.some(kw => queryLower === kw))) {
    return {
      currentNode: "sync_node",
      messages: [new AIMessage("Perfeito! Pode me dizer qual é a sua dúvida? Estou aqui para ajudar. 😊")],
    };
  }

  // 1. Inicializa embeddings e vector store (PGVectorStore — produção)
  const embeddings = new OpenAIEmbeddings({
    model: process.env.OPENAI_EMBEDDING_MODEL || "text-embedding-3-small",
    apiKey: process.env.OPENAI_API_KEY,
  });

  let vectorStore: PGVectorStore;
  try {
    vectorStore = await PGVectorStore.initialize(embeddings, {
      postgresConnectionOptions: { connectionString: DATABASE_URL },
      tableName: "knowledge_embeddings",
      columns: {
        idColumnName: "id",
        vectorColumnName: "embedding",
        contentColumnName: "content",
        metadataColumnName: "metadata",
      },
    });
  } catch (err) {
    console.error("[RAG Node] Erro ao conectar PGVectorStore:", err);
    return {
      currentNode: "sync_node",
      messages: [
        new AIMessage(
          "No momento estou com uma instabilidade técnica para acessar meus documentos jurídicos. Mas não se preocupe, já avisei nossa equipe técnica! Pode tentar me perguntar outra coisa?"
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

  // 5. Se sem chunks ou LLM indicou falta de informação → NÃO acionamos handoff automático de pausa,
  // apenas informamos e deixamos o usuário decidir ou continuar a triagem.
  let finalResponseText = responseText;
  const isInformationMissing = relevantDocs.length === 0 || containsHandoffIndicator(responseText);

  // 6. Se a triagem ainda não acabou, convidamos o usuário a continuar após a resposta
  if (state.triage.currentStep !== "DONE") {
    const stepLabels: Record<string, string> = {
      NAME: "seu nome completo",
      CPF: "seu CPF",
      CASE_TYPE: "o tipo do seu caso",
      DESCRIPTION: "uma breve descrição do que aconteceu",
      URGENCY: "a urgência do seu caso",
      AVAILABILITY: "sua disponibilidade para um contato",
    };
    const nextLabel = stepLabels[state.triage.currentStep] || "continuar sua triagem";
    
    if (isInformationMissing) {
      finalResponseText = "Não tenho essa informação específica na minha base de conhecimento no momento. 😕\n\nMas não se preocupe! Podemos continuar sua triagem para que um advogado veja seu caso, ou você pode aguardar um retorno humano (em até 24h). Para prosseguirmos agora, poderia me dizer " + nextLabel + "?";
    } else {
      finalResponseText += `\n\nConsegui te ajudar? 😊 Para que eu possa passar seu caso para um advogado, precisamos terminar sua triagem. Poderia me dizer ${nextLabel}?`;
    }

    return {
      currentNode: "sync_node",
      needsHandoff: false,
      messages: [new AIMessage(finalResponseText)],
    };
  }

  // Se já for cliente/lead e não encontramos a info, oferecemos ajuda com outras coisas
  if (isInformationMissing) {
    return {
      currentNode: "sync_node",
      messages: [new AIMessage("Peço desculpas, mas eu não tenho acesso a essa informação no momento. Posso ajudar você de outra forma?")],
    };
  }

  return {
    currentNode: "sync_node",
    needsHandoff: false,
    messages: [new AIMessage(finalResponseText)],
  };
}
