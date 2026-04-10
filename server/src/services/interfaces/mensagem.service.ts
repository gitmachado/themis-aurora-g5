import type { Mensagem } from '@models';
import type { CreateMensagemDTO } from '@dtos';

export interface IMensagemService {
  saveFromBot(dto: CreateMensagemDTO): Promise<Mensagem>;
  getHistoryByLead(leadId: string): Promise<Mensagem[]>;
  getHistoryByUser(userId: string): Promise<Mensagem[]>;
}
