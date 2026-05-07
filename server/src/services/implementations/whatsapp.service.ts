import { IWhatsAppService } from '../interfaces/whatsapp.service';

export class WhatsAppService implements IWhatsAppService {
  private readonly waAccessToken: string;
  private readonly waPhoneNumberId: string;
  private readonly waApiUrl: string;

  constructor() {
    this.waAccessToken = process.env.WA_ACCESS_TOKEN || '';
    this.waPhoneNumberId = process.env.WA_PHONE_NUMBER_ID || '';
    this.waApiUrl = `https://graph.facebook.com/v20.0/${this.waPhoneNumberId}/messages`;
  }

  async sendText(to: string, text: string): Promise<string> {
    if (!this.waAccessToken || !this.waPhoneNumberId) {
      console.warn('[WhatsApp] WA_ACCESS_TOKEN ou WA_PHONE_NUMBER_ID não configurados.');
      return 'fake-id-' + Date.now();
    }

    try {
      const response = await fetch(this.waApiUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.waAccessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          recipient_type: 'individual',
          to,
          type: 'text',
          text: { body: text },
        }),
      });

      const data = (await response.json()) as {
        error?: { message?: string };
        messages?: Array<{ id?: string }>;
      };

      if (!response.ok) {
        console.error(`[WhatsApp] Erro 401/Auth no envio para ${to}. Token inicia com: ${this.waAccessToken.substring(0, 7)}... ID: ${this.waPhoneNumberId}`);
        console.error('[WhatsApp] Detalhes do erro:', JSON.stringify(data, null, 2));
        throw new Error(data.error?.message || 'Erro ao enviar mensagem no WhatsApp');
      }

      console.log(`[WhatsApp] Mensagem enviada com sucesso para ${to}`);
      return data.messages?.[0]?.id || 'unknown-id';
    } catch (error) {
      console.error('[WhatsApp] Erro na requisio:', error);
      throw error;
    }
  }
}
