import type { MessageSender } from '@enums';

export interface CreateMessageDTO {
  whatsappNumber?: string; // Opcional, usado para encontrar userId/leadId se não fornecidos
  leadId?: string;
  userId?: string;
  sender: MessageSender;
  senderRole?: MessageSender; // Alias para compatibilidade com o bot
  messageType?: 'TEXT' | 'IMAGE' | 'DOCUMENT';
  content: string;
  whatsappMessageId?: string;
}

export interface SendMessageDTO {
  whatsappNumber: string;
  content: string;
  lawyerId: string;
}
