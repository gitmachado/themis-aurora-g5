/**
 * Serviço para enviar notificações via WhatsApp quando agendamentos são aprovados.
 * Integra com a IA para comunicar ao cliente a confirmação da reunião.
 */
export class AppointmentWhatsAppNotifier {
  private readonly WA_ACCESS_TOKEN = process.env.WA_ACCESS_TOKEN || '';
  private readonly WA_PHONE_NUMBER_ID = process.env.WA_PHONE_NUMBER_ID || '';
  private readonly WA_API_URL = `https://graph.facebook.com/v20.0/${this.WA_PHONE_NUMBER_ID}/messages`;

  /**
   * Envia mensagem de confirmação de agendamento ao cliente via WhatsApp
   */
  async notifyAppointmentApproved(options: {
    clientWhatsapp: string;
    clientName: string;
    appointmentTitle: string;
    scheduledAt: Date;
    hadEdits: boolean;
  }): Promise<void> {
    if (!options.clientWhatsapp) {
      console.warn('[AppointmentWhatsAppNotifier] Número de WhatsApp do cliente não fornecido');
      return;
    }

    try {
      const formattedDate = this.formatDatePT(options.scheduledAt);

      const message = `✅ *Reunião Confirmada!*\n\nOlá ${options.clientName}!\n\nSua reunião foi *confirmada com sucesso*.\n\n📅 *Data/Hora:* ${formattedDate}\n📋 *Assunto:* ${options.appointmentTitle}\n\nO advogado revisará todos os detalhes e estará pronto para sua reunião.`;

      await this.sendMessage(options.clientWhatsapp, message);
    } catch (err) {
      console.error('[AppointmentWhatsAppNotifier] Erro ao notificar cliente:', err);
    }
  }

  /**
   * Envia mensagem de rejeição de agendamento ao cliente
   */
  async notifyAppointmentRejected(options: {
    clientWhatsapp: string;
    clientName: string;
    appointmentTitle: string;
  }): Promise<void> {
    if (!options.clientWhatsapp) {
      console.warn('[AppointmentWhatsAppNotifier] Número de WhatsApp do cliente não fornecido');
      return;
    }

    try {
      const message = `⚠️ *Reunião Não Confirmada*\n\nOlá ${options.clientName}!\n\nInfelizmente, sua solicitação de reunião sobre "${options.appointmentTitle}" não foi confirmada neste momento.\n\nPor favor, entre em contato conosco para reagendar para um melhor horário.`;

      await this.sendMessage(options.clientWhatsapp, message);
    } catch (err) {
      console.error('[AppointmentWhatsAppNotifier] Erro ao notificar rejeição:', err);
    }
  }

  private async sendMessage(to: string, text: string, attempt = 1): Promise<void> {
    if (!this.WA_ACCESS_TOKEN || !this.WA_PHONE_NUMBER_ID) {
      console.warn('[AppointmentWhatsAppNotifier] WhatsApp token ou phone ID não configurados');
      return;
    }

    try {
      const response = await fetch(this.WA_API_URL, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.WA_ACCESS_TOKEN}`,
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

      if (!response.ok) {
        const status = response.status;
        const data = await response.json();

        // Retry com backoff exponencial para rate limit (429)
        if (status === 429 && attempt <= 3) {
          const delay = 1000 * Math.pow(2, attempt - 1);
          console.warn(
            `[AppointmentWhatsAppNotifier] Rate limit (429). Retry ${attempt}/3 em ${delay}ms`
          );
          await new Promise(resolve => setTimeout(resolve, delay));
          return this.sendMessage(to, text, attempt + 1);
        }

        console.error(
          `[AppointmentWhatsAppNotifier] Erro ao enviar para ${to} (status ${status}):`,
          data
        );
        return;
      }

      console.log(`[AppointmentWhatsAppNotifier] Mensagem enviada para ${to}`);
    } catch (err: any) {
      console.error(
        `[AppointmentWhatsAppNotifier] Erro ao enviar para ${to}:`,
        err.message
      );
    }
  }

  private formatDatePT(date: Date): string {
    return new Intl.DateTimeFormat('pt-BR', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZone: 'America/Sao_Paulo',
    }).format(date);
  }
}
