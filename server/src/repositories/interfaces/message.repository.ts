import type { Message } from '@models';

export interface IMessageRepository {
  findById(id: string): Promise<Message | null>;
  findByLeadId(leadId: string): Promise<Message[]>;
  findByUserId(userId: string): Promise<Message[]>;
  create(message: Omit<Message, 'id' | 'createdAt'>): Promise<Message>;
}
