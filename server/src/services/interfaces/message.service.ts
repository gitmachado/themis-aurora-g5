import type { Message } from '@models';
import type { CreateMessageDTO, SendMessageDTO } from '@dtos';

export interface IMessageService {
  saveFromBot(dto: CreateMessageDTO): Promise<Message>;
  sendMessage(dto: SendMessageDTO): Promise<Message>;
  getHistoryByLead(leadId: string): Promise<Message[]>;
  getHistoryByUser(userId: string): Promise<Message[]>;
  getHistoryByPhone(phone: string): Promise<Message[]>;
}
