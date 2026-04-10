import type { Mensagem } from '@models';

export interface IMensagemRepository {
  findById(id: string): Promise<Mensagem | null>;
  findByLeadId(leadId: string): Promise<Mensagem[]>;
  findByUserId(userId: string): Promise<Mensagem[]>;
  create(mensagem: Omit<Mensagem, 'id' | 'createdAt'>): Promise<Mensagem>;
}
