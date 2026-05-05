import type { MessageSender } from '@enums';

export interface Message {
  id: string;
  leadId: string | null;
  userId: string | null;
  whatsappNumber: string | null;
  sender: MessageSender;
  content: string;
  whatsappMessageId: string | null;
  createdAt: Date;
}
