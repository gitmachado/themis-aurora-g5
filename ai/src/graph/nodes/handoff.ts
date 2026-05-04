import { AIMessage } from "@langchain/core/messages";
import { ThemisStateType } from "../state.js";
import { notifyLawyer, startHandoff } from "../../utils/backend-client.js";
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

export async function handoffNode(
  state: ThemisStateType
): Promise<Partial<ThemisStateType>> {
  const { whatsappNumber, handoffReason, triage } = state;

  // 1. APENAS NOTIFICA (Handoff Passivo)
  try {
    await notifyLawyer({
      type: "HANDOFF",
      message: handoffReason || "Cliente solicita atendimento humano",
      whatsappNumber,
    });
  } catch (err: any) {
    console.error("[Handoff Node] Erro ao notificar:", err?.response?.data || err.message);
  }

  // 2. Retorna estado com mensagem amigável, mas mantém IA ATIVA (needsHandoff: false ou state.needsHandoff)
  const isTriageDone = triage.currentStep === "DONE";
  const replyMessage = isTriageDone
    ? "Compreendo. Já notifiquei um de nossos advogados especialistas sobre sua solicitação e ele entrará em contato com você por aqui assim que possível! 😊 Enquanto isso, se tiver mais alguma dúvida, pode me perguntar."
    : "Entendido! Já avisei um advogado sobre o seu caso. Para adiantar o atendimento, você gostaria de continuar respondendo as perguntinhas da triagem comigo agora ou prefere aguardar o contato dele?";

  return {
    currentNode: "sync_node",
    messages: [new AIMessage(replyMessage)],
    needsHandoff: state.needsHandoff, // Não força a pausa!
  };
}
