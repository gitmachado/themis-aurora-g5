import { syncMessage as syncToBackend } from "../../utils/backend-client.js";

export async function syncMessage(data: {
  whatsappNumber: string;
  content: string;
  senderRole: "CLIENT" | "BOT";
  messageType: "TEXT" | "IMAGE" | "DOCUMENT";
  whatsappMessageId: string | null;
}) {
  try {
    await syncToBackend({
      whatsappNumber: data.whatsappNumber,
      content: data.content,
      senderRole: data.senderRole,
      messageType: data.messageType,
      whatsappMessageId: data.whatsappMessageId,
    });
  } catch (err: any) {
    // Sync não deve bloquear o fluxo do bot — log e segue
    console.error("[Sync Node] Erro ao sincronizar mensagem:", err?.response?.data || err.message);
  }
}
