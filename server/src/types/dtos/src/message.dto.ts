import type { MessageSender } from '@enums';

export interface CreateMessageDTO {
  leadId?: string;
  userId?: string;
  whatsappNumber?: string;
  sender: MessageSender;
  content: string;
  whatsappMessageId?: string;
}
