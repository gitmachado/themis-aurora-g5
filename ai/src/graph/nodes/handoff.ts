import { AIMessage } from "@langchain/core/messages";
import { interrupt } from "@langchain/langgraph";
import axios from "axios";
import { OmniStateType } from "../state.js";
import { HANDOFF_MESSAGE } from "../../config/prompts.js";

const BACKEND_API_URL = process.env.BACKEND_API_URL || "http://localhost:3000";
const BOT_API_KEY = process.env.BOT_API_KEY || "";

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
  try {
    await axios.post(
      `${BACKEND_API_URL}/api/v1/notifications`,
      {
        type: "HUMAN_SUPPORT",
        title: "Solicitação de Atendimento Humano",
        body: handoffReason || "Cliente solicitou falar com um advogado.",
        extraData: { whatsappNumber, leadId, handoffReason },
      },
      { headers: { "x-api-key": BOT_API_KEY } }
    );
  } catch (err) {
    console.error("[Handoff Node] Erro ao notificar advogado:", err);
    // Graceful degradation — o interrupt ainda acontece
  }
}

export async function handoffNode(
  state: OmniStateType
): Promise<Partial<OmniStateType>> {
  const { whatsappNumber, handoffReason, leadId } = state;

  // 1. Notifica o advogado via backend
  await notifyLawyer(whatsappNumber, handoffReason, leadId);

  // 2. Pausa o grafo até intervenção humana (Human-in-the-loop)
  interrupt("HANDOFF_IN_PROGRESS");

  // 3. Retorna estado com mensagem de transferência ao cliente
  return {
    currentNode: "sync",
    needsHandoff: true,
    messages: [new AIMessage(HANDOFF_MESSAGE)],
  };
}
