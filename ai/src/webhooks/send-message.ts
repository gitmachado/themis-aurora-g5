import axios, { AxiosError } from "axios";

async function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export async function sendWhatsAppMessage(
  to: string,
  text: string,
  attempt = 1
): Promise<void> {
  const WA_ACCESS_TOKEN = process.env.WA_ACCESS_TOKEN || "";
  const WA_PHONE_NUMBER_ID = process.env.WA_PHONE_NUMBER_ID || "";
  const WA_API_URL = `https://graph.facebook.com/v20.0/${WA_PHONE_NUMBER_ID}/messages`;

  try {
    await axios.post(
      WA_API_URL,
      {
        messaging_product: "whatsapp",
        recipient_type: "individual",
        to,
        type: "text",
        text: { body: text },
      },
      {
        headers: {
          Authorization: `Bearer ${WA_ACCESS_TOKEN}`,
          "Content-Type": "application/json",
        },
      }
    );
    console.log(`[WhatsApp] Mensagem enviada para ${to}`);
  } catch (err) {
    const error = err as AxiosError;
    const status = error.response?.status;

    // Retry com backoff exponencial para rate limit (429)
    if (status === 429 && attempt <= 3) {
      const delay = 1000 * Math.pow(2, attempt - 1);
      console.warn(`[WhatsApp] Rate limit (429). Retry ${attempt}/3 em ${delay}ms`);
      await sleep(delay);
      return sendWhatsAppMessage(to, text, attempt + 1);
    }

    console.error(
      `[WhatsApp] Erro ao enviar para ${to} (status ${status}). Token inicia com: ${WA_ACCESS_TOKEN.substring(0, 7)}...`,
      error.response?.data ?? error.message
    );
  }
}
