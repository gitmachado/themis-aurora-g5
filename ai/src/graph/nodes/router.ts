import { ChatOpenAI } from "@langchain/openai";
import { ToolMessage } from "@langchain/core/messages";
import { ThemisStateType } from "../state.js";
import { AGENT_PROMPT } from "../../config/prompts.js";
import { tools, toolsByName } from "../../tools/index.js";
import { searchKnowledge } from "../../utils/vector-store.js";
import { getProcessesByPhone } from "../../utils/backend-client.js";

/**
 * Nó principal — Agente Unificado.
 * Recebe a mensagem do usuário, busca contexto (RAG + processos),
 * e decide como responder usando LLM + Tools.
 */
export async function routerNode(
  state: ThemisStateType
): Promise<Partial<ThemisStateType>> {
  const { whatsappNumber, messages, needsHandoff, triage } = state;

  // 1. Blindagem de Handoff — se IA está pausada, não processa
  if (needsHandoff === true) {
    return { currentNode: "sync_node" };
  }

  const lastMessage = String(messages.at(-1)?.content ?? "").trim();
  
  // 2. Modelo vinculado com as Tools modulares
  const model = new ChatOpenAI({
    model: process.env.OPENAI_MODEL || "gpt-4o-mini",
    temperature: 0.1,
  }).bindTools(tools);

  // 3. Busca de Conhecimento (RAG) — REMOVIDO (IA agora usa a tool pesquisar_conhecimento)
  const knowledgeContext = "Use a tool 'pesquisar_conhecimento' se precisar de informações do escritório.";

  // 4. Dados de Processos (se for cliente)
  let processContext = "Nenhum processo encontrado.";
  try {
    const processes = await getProcessesByPhone(whatsappNumber);
    if (processes.length > 0) {
      processContext = JSON.stringify(processes);
    }
  } catch (err) {
    console.warn("[Router Node] Erro ao buscar processos (continuando sem):", err);
  }

  // 5. Monta o prompt do agente com dados dinâmicos
  const agentPrompt = AGENT_PROMPT
    .replace("{triageName}", triage.name || "FALTANDO")
    .replace("{triageEmail}", triage.email || "FALTANDO")
    .replace("{triageCpf}", triage.cpf || "FALTANDO")
    .replace("{whatsappNumber}", whatsappNumber)
    .replace("{triageCaseType}", triage.caseType || "FALTANDO")
    .replace("{triageDescription}", triage.caseDescription || "FALTANDO")
    .replace("{triageUrgency}", triage.urgency || "FALTANDO")
    .replace("{triageAvailability}", triage.contactAvailability || "FALTANDO")
    .replace("{processContext}", processContext);

  // 6. Histórico recente (janela deslizante)
  const history = messages.slice(-20).map((m: any) => ({
    role: (m._getType?.() === 'ai' || m.type === 'ai') ? 'assistant' : 'user',
    content: String(m.content),
  }));

  // 7. Invoca o modelo
  let response;
  try {
    response = await model.invoke([
      { role: "system", content: agentPrompt },
      ...history,
    ]);
  } catch (err) {
    console.error("[Router Node] Erro ao invocar LLM:", err);
    const { AIMessage } = await import("@langchain/core/messages");
    return {
      currentNode: "sync_node",
      messages: [new AIMessage("Desculpe, tive um probleminha técnico. Pode repetir o que disse?")],
    };
  }

  // 8. Execução de Tools Reais
  if (response.tool_calls && response.tool_calls.length > 0) {
    const toolMessages: ToolMessage[] = [];

    console.log(`[Router Node] Executando ${response.tool_calls.length} tool(s)...`);

    for (const toolCall of response.tool_calls) {
      const toolFn = toolsByName[toolCall.name];
      if (toolFn) {
        try {
          const args = { ...toolCall.args, whatsappNumber };
          const result = await toolFn.invoke(args);
          console.log(`[Router Node] Tool ${toolCall.name} retornou: ${result}`);
          toolMessages.push(new ToolMessage({
            tool_call_id: toolCall.id!,
            content: String(result),
          }));
        } catch (toolErr) {
          console.error(`[Router Node] Erro na tool ${toolCall.name}:`, toolErr);
          toolMessages.push(new ToolMessage({
            tool_call_id: toolCall.id!,
            content: "ERRO_TECNICO: Falha ao executar esta operação.",
          }));
        }
      } else {
        console.warn(`[Router Node] Tool desconhecida: ${toolCall.name}`);
        toolMessages.push(new ToolMessage({
          tool_call_id: toolCall.id!,
          content: `ERRO: Tool '${toolCall.name}' não encontrada.`,
        }));
      }
    }

    // 9. Reflexão: IA recebe o resultado das tools e gera o texto final
    let finalResponse;
    try {
      finalResponse = await model.invoke([
        { role: "system", content: agentPrompt },
        ...history,
        response,
        ...toolMessages,
      ]);
    } catch (err) {
      console.error("[Router Node] Erro na reflexão pós-tool:", err);
      const { AIMessage } = await import("@langchain/core/messages");
      return {
        currentNode: "sync_node",
        messages: [response, ...toolMessages, new AIMessage("Pronto! Seus dados foram processados. Como posso ajudar mais?")],
      };
    }

    return {
      currentNode: "sync_node",
      messages: [response, ...toolMessages, finalResponse],
      needsHandoff: state.needsHandoff,
    };
  }

  // 10. Resposta sem tools
  return {
    currentNode: "sync_node",
    messages: [response],
  };
}
