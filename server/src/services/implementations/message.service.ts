import { IMessageService } from '../interfaces/message.service';
import { IMessageRepository } from '../../repositories/interfaces/message.repository';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import { ILeadRepository } from '../../repositories/interfaces/lead.repository';
import { IWhatsAppService } from '../interfaces/whatsapp.service';
import type { Message } from '@models';
import type { CreateMessageDTO, SendMessageDTO } from '@dtos';
import { eventBus } from '../communication/InternalEventBus';

export class MessageService implements IMessageService {
  constructor(
    private readonly messageRepository: IMessageRepository,
    private readonly userRepository: IUserRepository,
    private readonly leadRepository: ILeadRepository,
    private readonly whatsappService: IWhatsAppService
  ) {}

  async saveFromBot(dto: CreateMessageDTO): Promise<Message> {
    let finalUserId = dto.userId || null;
    let finalLeadId = dto.leadId || null;

    // Se não temos IDs mas temos o número de telefone, buscamos no banco
    if (!finalUserId && !finalLeadId && dto.whatsappNumber) {
      console.log(`[MessageService] Buscando vínculo para o número: ${dto.whatsappNumber}`);
      const user = await this.userRepository.findByWhatsapp(dto.whatsappNumber);
      if (user) {
        console.log(`[MessageService] Usuário encontrado: ${user.id}`);
        finalUserId = user.id;
      } else {
        const lead = await this.leadRepository.findByWhatsapp(dto.whatsappNumber);
        if (lead) {
          console.log(`[MessageService] Lead encontrado: ${lead.id}`);
          finalLeadId = lead.id;
        } else {
          console.log(`[MessageService] Nenhum vínculo encontrado para: ${dto.whatsappNumber}`);
        }
      }
    }

    const message = await this.messageRepository.create({
      leadId: finalLeadId,
      userId: finalUserId,
      whatsappNumber: dto.whatsappNumber || null,
      content: dto.content,
      sender: dto.sender || dto.senderRole!,
      whatsappMessageId: dto.whatsappMessageId || null,
    });

    // Notify via Socket.io
    if (dto.whatsappNumber) {
      eventBus.emitMessage(dto.whatsappNumber, message);
    }

    return message;
  }

  async sendMessage(dto: SendMessageDTO): Promise<Message> {
    // 1. Identify target to associate correctly in DB
    const user = await this.userRepository.findByWhatsapp(dto.whatsappNumber);
    const lead = await this.leadRepository.findByWhatsapp(dto.whatsappNumber);

    // 2. Save to DB first
    // This ensures the lawyer sees the message in the chat immediately, even if Meta API fails
    const message = await this.messageRepository.create({
      leadId: lead?.id || null,
      userId: user?.id || null,
      whatsappNumber: dto.whatsappNumber,
      content: dto.content,
      sender: 'LAWYER',
      whatsappMessageId: null, // Will be updated if WA send succeeds (optional optimization)
    });

    // Notify via Socket.io immediately
    if (dto.whatsappNumber) {
      eventBus.emitMessage(dto.whatsappNumber, message);
    }

    // 3. Send via WhatsApp (Do not await to not block the UI response if it's slow/failing)
    // But we catch errors to log them
    this.whatsappService.sendText(dto.whatsappNumber, dto.content)
      .then(waId => {
        console.log(`[MessageService] Mensagem enviada para WhatsApp: ${dto.whatsappNumber}, WA_ID: ${waId}`);
      })
      .catch(err => {
        console.error(`[MessageService] Falha no envio WhatsApp (mas mensagem foi salva no banco): ${err.message}`);
      });

    return message;
  }

  async getHistoryByLead(leadId: string): Promise<Message[]> {
    return this.messageRepository.findByLeadId(leadId);
  }

  async getHistoryByUser(userId: string): Promise<Message[]> {
    return this.messageRepository.findByUserId(userId);
  }

  async getHistoryByPhone(phone: string): Promise<Message[]> {
    console.log(`[MessageService] Buscando histórico para o número: ${phone}`);
    const messages = await this.messageRepository.findByWhatsappNumber(phone);
    console.log(`[MessageService] Foram encontradas ${messages.length} mensagens para o número: ${phone}`);

    // Ordena por data de criação
    return messages.sort((a, b) => 
      (a.createdAt?.getTime() || 0) - (b.createdAt?.getTime() || 0)
    );
  }
}
