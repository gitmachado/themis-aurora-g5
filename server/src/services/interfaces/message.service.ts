import type { Message } from '@models';
import type { CreateMessageDTO } from '@dtos';

export interface IMessageService {
  saveFromBot(dto: CreateMessageDTO): Promise<Message>;
  getHistoryByLead(leadId: string): Promise<Message[]>;
  getHistoryByUser(userId: string): Promise<Message[]>;
}
