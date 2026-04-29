import { AIMessage } from "@langchain/core/messages";
import { interrupt } from "@langchain/langgraph";
import { OmniStateType } from "../state.js";
import { HANDOFF_MESSAGE } from "../../config/prompts.js";

// Palavras-chave que disparam handoff (verificação determinística, antes do LLM)
const HANDOFF_KEYWORDS = [
  "ajuda",
  "falar com alguem",
  "falar com alguém",
  "advogado",
  "humano",
  "pessoa real",
  "atendimento humano",
];

export function detectHandoffKeyword(message: string): boolean {
  const lower = message.toLowerCase();
  return HANDOFF_KEYWORDS.some((kw) => lower.includes(kw));
}

async function notifyLawyer(
  whatsappNumber: string,
  handoffReason: string | null,
  leadId: string | null
): Promise<void> {
  // MOCK: Para garantir independencia
  console.log("[Handoff Node] MOCK: Notificando advogado para atendimento humano", {
    whatsappNumber,
    handoffReason,
    leadId
  });
}

export async function handoffNode(
  state: OmniStateType
): Promise<Partial<OmniStateType>> {
  const { whatsappNumber, handoffReason, leadId } = state;

  // 1. Notifica o advogado via backend
  await notifyLawyer(whatsappNumber, handoffReason, leadId);

  // 2. Retorna estado com mensagem de transferência ao cliente
  // Nota: Removido interrupt() pois ele impediria o bot de responder a última mensagem.
  return {
    currentNode: "sync_node",
    needsHandoff: true,
    messages: [new AIMessage(HANDOFF_MESSAGE)],
  };
}
