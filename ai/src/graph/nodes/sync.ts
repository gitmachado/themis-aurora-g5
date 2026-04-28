import axios from "axios";

// TODO: Chamar syncMessage() aqui quando T19 (Webhook receptor)
// for implementada — sender = "CLIENT" ao receber mensagem
// e sender = "BOT" ao enviar resposta

export async function syncMessage(data: {
  whatsappNumber: string;
  content: string;
  senderRole: "CLIENT" | "BOT";
  messageType: "TEXT" | "IMAGE" | "DOCUMENT";
  whatsappMessageId: string | null;
}) {
  try {
    const BACKEND_API_URL = process.env.BACKEND_API_URL || "";
    const BOT_API_KEY = process.env.BOT_API_KEY || "";

    await axios.post(`${BACKEND_API_URL}/api/v1/messages/sync`, data, {
      headers: { "x-api-key": BOT_API_KEY },
    });
  } catch (error) {
    console.error("[Sync Node] Erro ao sincronizar mensagem com o backend:", error);
    // Não repassa o erro para não quebrar o fluxo do bot
  }
}
