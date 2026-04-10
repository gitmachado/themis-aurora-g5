import type { RemetenteMensagem } from '@enums';

export interface Mensagem {
  id: string;
  leadId: string | null;
  userId: string | null;
  remetente: RemetenteMensagem;
  conteudo: string;
  whatsappMessageId: string | null;
  createdAt: Date;
}
