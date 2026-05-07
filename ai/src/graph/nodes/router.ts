import { ChatOpenAI } from "@langchain/openai";
import { ToolMessage } from "@langchain/core/messages";
import { ThemisStateType } from "../state.js";
import { SYSTEM_PROMPT } from "../../config/prompts.js";
import { PGVectorStore } from "@langchain/community/vectorstores/pgvector";
import { OpenAIEmbeddings } from "@langchain/openai";
import { tools, toolsByName } from "../../tools/index.js";

const DATABASE_URL = process.env.DATABASE_URL || "postgresql://postgres:postgres@localhost:5433/themis_db";

export async function routerNode(
  state: ThemisStateType
): Promise<Partial<ThemisStateType>> {
  const { whatsappNumber, messages, needsHandoff, triage } = state;

  // 1. Blindagem de Handoff
  if (needsHandoff === true) return { currentNode: "sync_node" };

  const lastMessage = String(messages.at(-1)?.content ?? "").trim();
  
  // 2. Modelo vinculado com as Tools modulares
  const model = new ChatOpenAI({
    model: process.env.OPENAI_MODEL || "gpt-4o-mini",
    temperature: 0.1,
  }).bindTools(tools);

  // 3. Busca de Conhecimento (RAG)
  const embeddings = new OpenAIEmbeddings({ model: process.env.OPENAI_EMBEDDING_MODEL || "text-embedding-3-small" });
  let knowledgeContext = "Nenhuma informação encontrada.";
  try {
    const vectorStore = await PGVectorStore.initialize(embeddings, { postgresConnectionOptions: { connectionString: DATABASE_URL }, tableName: "knowledge_embeddings" });
    const docs = await vectorStore.similaritySearch(lastMessage, 3);
    if (docs.length > 0) knowledgeContext = docs.map(d => d.pageContent).join("\n---\n");
  } catch (err) {}

  // 3.5 Dados de Processos (se for cliente)
  let processContext = "Nenhum processo encontrado.";
  try {
    const { getProcessesByPhone } = await import("../../utils/backend-client.js");
    const processes = await getProcessesByPhone(whatsappNumber);
    if (processes.length > 0) processContext = JSON.stringify(processes);
  } catch (err) { /* ignore */ }

  // 4. Super Prompt de Agente Unificado
  const agentPrompt = `Você é a Themis, a assistente virtual oficial do nosso escritório. ⚖️

DIRETRIZES DE PERSONA:
- Sempre se identifique como Themis no primeiro contato.
- Seja profissional, humana e extremamente honesta.

SEGURANÇA (GUARDRAILS):
1. IDENTIDADE: Se perguntarem se o escritório é de outra pessoa (ex: "É do José?"), esclareça gentilmente que você é a assistente oficial deste escritório.
2. ESCOPO: Só fale sobre temas jurídicos. Se o assunto for aleatório (comida, receitas, etc), diga que seu foco é jurídico e convide o usuário a tirar uma dúvida sobre o escritório.

TRIAGEM FLUIDA (PT-BR):
1. Você deve coletar: Nome Completo, CPF, Tipo de Caso, Descrição do Caso e Disponibilidade de Contato.
2. IMPORTANTE: Você JÁ POSSUI o número do WhatsApp do cliente no sistema. NUNCA peça o número de telefone dele.
3. DETERMINAÇÃO DE URGÊNCIA E DESCRIÇÃO: Você NÃO deve perguntar a urgência ao cliente. Com base na descrição do caso, determine internamente se é Alta, Média ou Baixa. O campo 'Descrição' deve ser um resumo TÉCNICO e PROFISSIONAL escrito EM TERCEIRA PESSOA (Ex: "O cliente relata que...", "O interessado busca auxílio pois..."). Este resumo é apenas para registro interno e você NUNCA deve repetí-lo para o cliente.
4. Só chame 'registrar_triagem' quando tiver as 5 informações (Nome, CPF, Tipo, Descrição e Disponibilidade). Passe a Descrição já formatada em terceira pessoa e a Urgência determinada internamente. Use o 'whatsappNumber' da memória.

MEMÓRIA DE LONGO PRAZO:
- Nome: ${triage.name || "FALTANDO"}
- CPF: ${triage.cpf || "FALTANDO"}
- WhatsApp do Cliente: ${whatsappNumber} (NUNCA PERGUNTE ESTE DADO)
- Tipo Caso: ${triage.caseType || "FALTANDO"}
- Descrição: ${triage.caseDescription || "FALTANDO"}
- Urgência: ${triage.urgency || "FALTANDO"}
- Disponibilidade: ${triage.contactAvailability || "FALTANDO"}

CONHECIMENTO: ${knowledgeContext}
PROCESSOS: ${processContext}`;

  const history = messages.slice(-20).map((m: any) => ({
    role: (m._getType?.() === 'ai' || m.type === 'ai') ? 'assistant' : 'user',
    content: m.content
  }));

  const response = await model.invoke([
    { role: "system", content: agentPrompt },
    ...history,
  ]);

  // 5. Execução de Tools Reais
  if (response.tool_calls && response.tool_calls.length > 0) {
    const newMessages: any[] = [response];

    console.log(`[Router Node] Executando ${response.tool_calls.length} tool(s)...`);

    for (const toolCall of response.tool_calls) {
      const toolFn = toolsByName[toolCall.name];
      if (toolFn) {
        const args = { ...toolCall.args, whatsappNumber };
        const result = await toolFn.invoke(args);
        console.log(`[Router Node] Tool ${toolCall.name} retornou: ${result}`);
        newMessages.push(new ToolMessage({
          tool_call_id: toolCall.id!,
          content: result,
        }));
      }
    }

    // Segunda chamada (Reflexão): a IA recebe o resultado da tool e gera o texto final.
    const finalResponse = await model.invoke([
      { role: "system", content: agentPrompt },
      ...history,
      ...newMessages
    ]);

    return {
      currentNode: "sync_node",
      messages: [response, ...newMessages.filter(m => m instanceof ToolMessage), finalResponse],
      needsHandoff: state.needsHandoff, 
    };
  }

  return {
    currentNode: "sync_node",
    messages: [response],
  };
}
