import { IMessageService } from '../interfaces/message.service';
import { IMessageRepository } from '../../repositories/interfaces/message.repository';
import type { Message } from '@models';
import type { CreateMessageDTO } from '@dtos';

export class MessageService implements IMessageService {
  constructor(private readonly messageRepository: IMessageRepository) {}

  async saveFromBot(dto: CreateMessageDTO): Promise<Message> {
    return this.messageRepository.create({
      leadId: dto.leadId || null,
      userId: dto.userId || null,
      content: dto.content,
      sender: dto.sender,
      whatsappMessageId: dto.whatsappMessageId || null,
    });
  }

  async getHistoryByLead(leadId: string): Promise<Message[]> {
    return this.messageRepository.findByLeadId(leadId);
  }

  async getHistoryByUser(userId: string): Promise<Message[]> {
    return this.messageRepository.findByUserId(userId);
  }
}
