import { AIMessage } from "@langchain/core/messages";
import { ChatOpenAI } from "@langchain/openai";
import { ThemisStateType } from "../state.js";
import { getProcessesByPhone } from "../../utils/backend-client.js";
import { SYSTEM_PROMPT, STATUS_HUMANIZER_PROMPT } from "../../config/prompts.js";

const STATUS_LABELS: Record<string, string> = {
  OPEN: "Aberto",
  UNDER_ANALYSIS: "Em Análise",
  AWAITING_DOCUMENT: "Aguardando Documentos",
  COMPLETED: "Concluído",
  ARCHIVED: "Arquivado",
};

function formatDate(date: string | null): string {
  if (!date) return "—";
  return new Date(date).toLocaleDateString("pt-BR");
}

async function humanizeResponse(processes: any[]): Promise<string> {
  const model = new ChatOpenAI({
    model: process.env.OPENAI_MODEL || "gpt-4o-mini",
    temperature: 0.3,
  });

  const dataSummary = processes.map(p => ({
    titulo: p.title,
    numero: p.processNumber || "Não informado",
    status: STATUS_LABELS[p.currentStatus] ?? p.currentStatus,
    ultimaMovimentacao: formatDate(p.lastMovementDate),
    ultimaNota: p.lastNote || "Nenhuma observação"
  }));

  const prompt = STATUS_HUMANIZER_PROMPT.replace("{processData}", JSON.stringify(dataSummary, null, 2));

  const response = await model.invoke([
    { role: "system", content: SYSTEM_PROMPT },
    { role: "user", content: prompt }
  ]);

  return String(response.content);
}

export async function statusNode(
  state: ThemisStateType
): Promise<Partial<ThemisStateType>> {
  const { whatsappNumber, messages, interactionContext } = state;
  const userInput = String(messages.at(-1)?.content ?? "").trim();

  let processes: any[];
  try {
    processes = await getProcessesByPhone(whatsappNumber);
  } catch (err) {
    console.error("[Status Node] Erro ao buscar processos:", err);
    return {
      currentNode: "sync_node",
      messages: [
        new AIMessage("Não consegui consultar seus processos agora. Tente novamente em instantes."),
      ],
    };
  }

  // Se o usuário está em contexto de seleção e digitou um número
  const choice = parseInt(userInput, 10);
  if (interactionContext === "SELECTING_PROCESS" && !isNaN(choice) && choice >= 1 && choice <= processes.length) {
    const selected = processes[choice - 1];
    const humanResponse = await humanizeResponse([selected]);
    return {
      currentNode: "sync_node",
      interactionContext: null,
      messages: [new AIMessage(humanResponse)],
    };
  }

  // Resposta humanizada para todos os outros casos (0, 1 ou múltiplos)
  const humanResponse = await humanizeResponse(processes);
  
  return {
    currentNode: "sync_node",
    interactionContext: processes.length > 1 ? "SELECTING_PROCESS" : null,
    messages: [new AIMessage(humanResponse)],
  };
}
