import type { RemetenteMensagem } from '@enums';

export interface CreateMensagemDTO {
  leadId?: string;
  userId?: string;
  remetente: RemetenteMensagem;
  conteudo: string;
  whatsappMessageId?: string;
}
