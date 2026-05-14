import { ChatOpenAI } from "@langchain/openai";
import { ToolMessage } from "@langchain/core/messages";
import { ThemisStateType } from "../state.js";
import { AGENT_PROMPT } from "../../config/prompts.js";
import { tools, toolsByName } from "../../tools/index.js";
import { searchKnowledge } from "../../utils/vector-store.js";
import { getProcessesByPhone, getLeadByPhone, getOpenAppointmentsByPhone } from "../../utils/backend-client.js";

/**
 * Nó principal — Agente Unificado.
 * Recebe a mensagem do usuário, busca contexto (RAG + processos),
 * e decide como responder usando LLM + Tools.
 */
export async function routerNode(
  state: ThemisStateType
): Promise<Partial<ThemisStateType>> {
  let { whatsappNumber, messages, needsHandoff, triage } = state;

  // 1. Blindagem de Handoff — se IA está pausada, não processa
  if (needsHandoff === true) {
    return { currentNode: "sync_node" };
  }

  const lastMessage = String(messages.at(-1)?.content ?? "").trim();

  // 2. NOVO: Carregar Lead Existente se Triage está vazia
  // Soluciona o problema de perda de contexto entre mensagens
  if (!triage.name && whatsappNumber) {
    try {
      const existingLead = await getLeadByPhone(whatsappNumber);
      if (existingLead?.exists) {
        triage = {
          name: existingLead.name ?? null,
          email: existingLead.email ?? null,
          cpf: existingLead.cpf ?? null,
          caseType: existingLead.caseType ?? null,
          caseDescription: existingLead.caseDescription ?? null,
          urgency: existingLead.urgency ?? null,
          contactAvailability: existingLead.contactAvailability ?? null,
          currentStep: "DONE",
        };
        console.log(`[Router Node] Lead ${existingLead.name} carregado do banco para restaurar contexto.`);
      }
    } catch (err) {
      console.warn("[Router Node] Erro ao buscar lead existente (continuando sem):", err);
    }
  }

  // 3. PRÉ-CHECK para Bloqueio de Reuniões Abertas (se cliente quer marcar)
  let openAppointmentsContext = "";
  const bookingKeywords = ["marcar", "agendar", "reunião", "consulta com advogado", "nova reunião", "outra reunião", "sim", "claro", "pode", "blz", "ok", "tudo bem"];
  const wantsToBook = bookingKeywords.some(k => lastMessage.toLowerCase().includes(k));

  console.log(`[Router Node] Message received: "${lastMessage}" | wantsToBook: ${wantsToBook}`);

  if (triage.name && whatsappNumber && wantsToBook) {
    console.log(`[Router Node] 🔍 PRÉ-CHECK: Detectado booking intent para ${triage.name}`);
    try {
      const open = await getOpenAppointmentsByPhone(whatsappNumber);
      console.log(`[Router Node] ✅ getOpenAppointmentsByPhone retornou:`, open);

      if (open.hasOpenAppointments) {
        const details = open.appointments
          .map((a: any) => `${a.title} (${a.status})`)
          .join("; ");
        openAppointmentsContext = `\n\n⚠️ ALERTA SISTEMA: Cliente "${triage.name}" tem ${open.count} reunião(ões) ABERTA(S): ${details}. BLOQUEIE novo agendamento imediatamente e ofereça HANDOFF.`;
        console.log(`[Router Node] ❌ Cliente tem reunião aberta`);
      } else {
        openAppointmentsContext = `\n\n✅ SISTEMA: Cliente "${triage.name}" não tem reuniões abertas — PODE AGENDAR.`;
        console.log(`[Router Node] ✅ Cliente sem reuniões abertas`);
      }
    } catch (err) {
      console.error("[Router Node] ❌ Erro ao verificar reuniões:", err);
      openAppointmentsContext = `\n\n⚠️ ERRO: Não consegui verificar reuniões. Continuando...`;
    }
  }

  // 4. Modelo vinculado com as Tools modulares
  const model = new ChatOpenAI({
    model: process.env.OPENAI_MODEL || "gpt-4o-mini",
    temperature: 0.1,
  }).bindTools(tools);

  // 5. Busca de Conhecimento (RAG) — REMOVIDO (IA agora usa a tool pesquisar_conhecimento)
  const knowledgeContext = "Use a tool 'pesquisar_conhecimento' se precisar de informações do escritório.";

  // 6. Dados de Processos (se for cliente)
  let processContext = "Nenhum processo encontrado.";
  try {
    const processes = await getProcessesByPhone(whatsappNumber);
    if (processes.length > 0) {
      processContext = JSON.stringify(processes);
    }
  } catch (err) {
    console.warn("[Router Node] Erro ao buscar processos (continuando sem):", err);
  }

  // 7. Monta o prompt do agente com dados dinâmicos
  const now = new Date();
  const todayStr = now.toLocaleDateString('pt-BR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
  const todayISO = now.toISOString().split('T')[0];
  // Calcula o próximo sábado
  const daysUntilSaturday = (6 - now.getDay() + 7) % 7 || 7;
  const nextSat = new Date(now);
  nextSat.setDate(now.getDate() + daysUntilSaturday);
  const nextSaturdayISO = nextSat.toISOString().split('T')[0];

  const agentPrompt = AGENT_PROMPT
    .replace("{currentDate}", `${todayStr} (${todayISO})`)
    .replace("{nextSaturday}", nextSaturdayISO)
    .replace("{triageName}", triage.name || "FALTANDO")
    .replace("{triageEmail}", triage.email || "FALTANDO")
    .replace("{triageCpf}", triage.cpf || "FALTANDO")
    .replace("{whatsappNumber}", whatsappNumber)
    .replace("{triageCaseType}", triage.caseType || "FALTANDO")
    .replace("{triageDescription}", triage.caseDescription || "FALTANDO")
    .replace("{triageUrgency}", triage.urgency || "FALTANDO")
    .replace("{triageAvailability}", triage.contactAvailability || "FALTANDO")
    .replace("{processContext}", processContext)
    + openAppointmentsContext;

  // 8. Histórico recente (janela deslizante)
  const history = messages.slice(-20).map((m: any) => ({
    role: (m._getType?.() === 'ai' || m.type === 'ai') ? 'assistant' : 'user',
    content: String(m.content),
  }));

  // 9. Invoca o modelo
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

  // 10. Execução de Tools Reais
  if (response.tool_calls && response.tool_calls.length > 0) {
    const toolMessages: ToolMessage[] = [];


    for (const toolCall of response.tool_calls) {
      const toolFn = toolsByName[toolCall.name];
      if (toolFn) {
        try {
          const args = { ...toolCall.args, whatsappNumber };
          const result = await toolFn.invoke(args);
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

    // 11. Reflexão: IA recebe o resultado das tools e gera o texto final
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

  // 11. Resposta sem tools
  return {
    currentNode: "sync_node",
    messages: [response],
  };
}
