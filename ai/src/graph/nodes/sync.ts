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
  // MOCK: Independencia do modulo AI
  console.log("[Sync Node] MOCK: Sincronizando mensagem com backend", data);
}
