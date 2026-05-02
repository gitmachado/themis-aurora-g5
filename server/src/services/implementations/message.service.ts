import { IMessageService } from '../interfaces/message.service';
import { IMessageRepository } from '../../repositories/interfaces/message.repository';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import { ILeadRepository } from '../../repositories/interfaces/lead.repository';
import type { Message } from '@models';
import type { CreateMessageDTO } from '@dtos';

export class MessageService implements IMessageService {
  constructor(
    private readonly messageRepository: IMessageRepository,
    private readonly userRepository: IUserRepository,
    private readonly leadRepository: ILeadRepository
  ) {}

  async saveFromBot(dto: CreateMessageDTO): Promise<Message> {
    let leadId = dto.leadId || null;
    let userId = dto.userId || null;

    if (!leadId && !userId && dto.whatsappNumber) {
      const user = await this.userRepository.findByWhatsapp(dto.whatsappNumber);
      if (user) {
        userId = user.id;
      } else {
        const lead = await this.leadRepository.findByWhatsapp(dto.whatsappNumber);
        leadId = lead?.id || null;
      }
    }

    return this.messageRepository.create({
      leadId,
      userId,
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

  async getHistoryByPhone(phone: string): Promise<Message[]> {
    // 1. Check if it's a registered User
    const user = await this.userRepository.findByWhatsapp(phone);
    if (user) {
      return this.messageRepository.findByUserId(user.id);
    }

    // 2. Check if it's a Lead
    const lead = await this.leadRepository.findByWhatsapp(phone);
    if (lead) {
      return this.messageRepository.findByLeadId(lead.id);
    }

    return [];
  }
}
