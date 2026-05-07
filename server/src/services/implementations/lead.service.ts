import { ILeadService } from '../interfaces/lead.service';
import { ILeadRepository } from '../../repositories/interfaces/lead.repository';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import { IMessageRepository } from '../../repositories/interfaces/message.repository';
import { IAuthService } from '../interfaces/auth.service';
import { INotificationService } from '../interfaces/notification.service';
import { ILegalProcessService } from '../interfaces/legal-process.service';
import { IWhatsAppService } from '../interfaces/whatsapp.service';
import type { Lead, User } from '@models';
import type { CreateLeadDTO, ConvertLeadDTO } from '@dtos';
import { NotFoundError, BadRequestError } from './errors';
import { LeadStatus, UserRole } from '@enums';
import bcrypt from 'bcryptjs';
import { eventBus } from '../communication/InternalEventBus';
import { dbRun } from '../../config/database';

export class LeadService implements ILeadService {
  constructor(
    private readonly leadRepository: ILeadRepository,
    private readonly userRepository: IUserRepository,
    private readonly authService: IAuthService,
    private readonly notificationService: INotificationService,
    private readonly legalProcessService: ILegalProcessService,
    private readonly whatsAppService: IWhatsAppService,
    private readonly messageRepository: IMessageRepository
  ) {}

  async createFromWhatsapp(dto: CreateLeadDTO): Promise<Lead> {
    // Check if lead already exists for this number
    const existingLead = await this.leadRepository.findByWhatsapp(dto.whatsappNumber);
    if (existingLead) {
      return this.updateLeadData(existingLead.id, dto);
    }

    const caseDescription = dto.caseDescription ?? dto.description ?? '';

    const lead = await this.leadRepository.create({
      name: dto.name || null,
      whatsappNumber: dto.whatsappNumber,
      email: dto.email || null,
      cpf: dto.cpf || null,
      caseType: dto.caseType || null,
      caseDescription,
      urgency: dto.urgency || null,
      contactAvailability: dto.contactAvailability || null,
      status: 'PENDING',
      convertedUserId: null,
      assignedLawyerId: null,
      assignedLawyerName: null,
      lawyerNotes: null,
      discardReason: null,
      isAIPaused: false,
    });

    // Notify lawyers of new lead
    eventBus.emitLeadUpdate(lead);

    return lead;
  }

  async updateLeadData(id: string, data: Partial<CreateLeadDTO>): Promise<Lead> {
    console.log(`[LeadService] Iniciando atualização do lead ${id}`);
    const lead = await this.leadRepository.findById(id);
    if (!lead) {
      console.warn(`[LeadService] Lead ${id} não encontrado no banco`);
      throw new NotFoundError('Lead não encontrado');
    }

    // Cliente legado (bot) ainda envia `description`; normalizamos para
    // `caseDescription` e removemos a chave legada antes de persistir.
    const { description: legacyDescription, ...rest } = data;
    const normalizedData: Partial<Lead> = { ...rest };
    if (legacyDescription && !data.caseDescription) {
      normalizedData.caseDescription = legacyDescription;
    }

    const updatedLead = await this.leadRepository.update(id, normalizedData);
    
    // Notify updates
    eventBus.emitLeadUpdate(updatedLead);
    
    return updatedLead;
  }

  async convertToClient(dto: ConvertLeadDTO): Promise<User> {
    const lead = await this.leadRepository.findById(dto.leadId);
    if (!lead) {
      throw new NotFoundError('Lead não encontrado');
    }

    const wasAlreadyConverted =
      lead.status === 'CONVERTED' && Boolean(lead.convertedUserId);

    // Caminho idempotente: lead já convertido e ligado a um user existente.
    if (wasAlreadyConverted) {
      const linkedUser = await this.userRepository.findById(lead.convertedUserId!);
      if (linkedUser) {
        eventBus.emitLeadUpdate(lead);
        return linkedUser;
      }
      // Usuário ligado não existe mais (raro): segue o fluxo para recriar/relinkar.
    }

    const cpf = lead.cpf?.trim() || null;

    // Reaproveita user existente (whatsapp ou CPF) em vez de falhar com conflito.
    let user = await this.userRepository.findByWhatsapp(lead.whatsappNumber);
    if (!user && cpf) {
      user = await this.userRepository.findByCpf(cpf);
    }

    let tempPassword: string | null = null;
    if (!user) {
      tempPassword = this.authService.generateTempPassword();
      const passwordHash = await bcrypt.hash(tempPassword, 10);

      user = await this.userRepository.create({
        name: lead.name || 'Cliente',
        whatsappNumber: lead.whatsappNumber!,
        cpf,
        email: lead.email || null,
        avatarUrl: null,
        role: 'CLIENT',
        passwordHash,
        fcmToken: null,
        notificationPreferences: {
          push: true,
          whatsapp: true,
        },
        teamPermissions: {},
        lawyerAdminId: null,
        oabNumber: null,
        specialty: null,
        mustChangePassword: true,
      });
    }

    const updatedLead = await this.leadRepository.update(lead.id, {
      status: 'CONVERTED',
      convertedUserId: user.id,
      discardReason: null,
    });

    // Evita duplicar processo caso o lead já tivesse sido convertido antes.
    if (!wasAlreadyConverted) {
      await this.legalProcessService.create({
        clientId: user.id,
        lawyerId: dto.lawyerId,
        title: `${lead.caseType || 'Civil'} - ${lead.name || 'Cliente'}`,
        description: lead.caseDescription || '',
        caseType: lead.caseType || 'Civil',
      });
    }

    // Push só depois do processo criado, para o cliente já encontrar contexto ao logar.
    if (tempPassword) {
      // Envia credenciais via WhatsApp — o cliente ainda não tem o app
      const loginEmail = lead.email || user.email;
      const welcomeMessage = [
        `⚖️ *Bem-vindo(a) ao Themis, ${user.name}!*`,
        ``,
        `Seu cadastro foi aprovado e um advogado já está cuidando do seu caso.`,
        ``,
        `Baixe nosso aplicativo para acompanhar tudo em tempo real:`,
        `📧 *Login:* ${loginEmail}`,
        `🔐 *Senha temporária:* ${tempPassword}`,
        ``,
        `⚠️ No primeiro acesso, você precisará criar uma nova senha.`,
        ``,
        `Qualquer dúvida, estou aqui! 😊`,
      ].join('\n');

      try {
        await this.whatsAppService.sendText(lead.whatsappNumber, welcomeMessage);
        console.log(`[LeadService] Credenciais enviadas via WhatsApp para ${lead.whatsappNumber}`);
        
        // Salva a mensagem de boas-vindas no histórico para aparecer no app
        await this.messageRepository.create({
          whatsappNumber: lead.whatsappNumber,
          content: welcomeMessage,
          sender: 'BOT',
          leadId: lead.id,
          userId: user.id,
          whatsappMessageId: null,
        });
      } catch (waError) {
        console.error('[LeadService] Erro ao enviar/salvar credenciais:', waError);
      }

      // Push como fallback (caso já tenha o app instalado)
      await this.notificationService.sendPush(
        user.id,
        'Seu acesso ao Themis',
        `Bem-vindo! Use a senha temporária: ${tempPassword}`
      ).catch(() => {});
    }

    eventBus.emitLeadUpdate(updatedLead);

    return user;
  }

  async discard(id: string, reason?: string): Promise<Lead> {
    const lead = await this.leadRepository.findById(id);
    if (!lead) {
      throw new NotFoundError('Lead não encontrado');
    }

    const updatedLead = await this.leadRepository.update(id, {
      status: 'DISCARDED',
      discardReason: reason || null,
    });

    // Notify update via Socket
    eventBus.emitLeadUpdate(updatedLead);

    return updatedLead;
  }

  async getPending(): Promise<Lead[]> {
    return this.leadRepository.findPending();
  }

  async getAll(): Promise<Lead[]> {
    return this.leadRepository.findAll();
  }

  async getByStatus(status: LeadStatus): Promise<Lead[]> {
    return this.leadRepository.findByStatus(status);
  }

  async getById(id: string): Promise<Lead | null> {
    return this.leadRepository.findById(id);
  }

  async getByWhatsapp(whatsappNumber: string): Promise<Lead | null> {
    return this.leadRepository.findByWhatsapp(whatsappNumber);
  }

  async resumeAISupport(whatsappNumber: string): Promise<void> {
    const aiModuleUrl = process.env.AI_MODULE_URL || 'http://localhost:3001';
    
    try {
      // 1. Atualiza no Banco de Dados
      const lead = await this.leadRepository.findByWhatsapp(whatsappNumber);
      if (lead) {
        await this.leadRepository.update(lead.id, { 
          isAIPaused: false,
          assignedLawyerId: null 
        });
        
        // Notify unlock
        eventBus.emitLeadUnlocked(lead.id, lead.whatsappNumber);
      }

      // 2. Notifica Módulo de IA
      const response = await fetch(`${aiModuleUrl}/handoff/resume`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ whatsappNumber }),
      });

      if (!response.ok) {
        const error = (await response.json()) as { error?: string };
        throw new Error(error.error || 'Falha ao retomar atendimento da IA');
      }

      console.log(`[LeadService] Sinal de retomada enviado para IA e banco atualizado (${whatsappNumber})`);
    } catch (error) {
      console.error('[LeadService] Erro ao comunicar com módulo de IA:', error);
      throw error;
    }
  }

  async startHandoffSupport(whatsappNumber: string): Promise<void> {
    const aiModuleUrl = process.env.AI_MODULE_URL || 'http://localhost:3001';
    
    try {
      // 1. Atualiza no Banco de Dados
      const lead = await this.leadRepository.findByWhatsapp(whatsappNumber);
      if (lead) {
        await this.leadRepository.update(lead.id, { isAIPaused: true });
      }

      // 2. Notifica Módulo de IA
      const response = await fetch(`${aiModuleUrl}/handoff/start`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ whatsappNumber }),
      });

      if (!response.ok) {
        const error = (await response.json()) as { error?: string };
        throw new Error(error.error || 'Falha ao iniciar handoff para humano');
      }

      console.log(`[LeadService] Sinal de handoff iniciado enviado para IA e banco atualizado (${whatsappNumber})`);
    } catch (error) {
      console.error('[LeadService] Erro ao comunicar com módulo de IA:', error);
      throw error;
    }
  }

  async assignToLawyer(leadId: string, lawyerId: string): Promise<void> {
    const lead = await this.leadRepository.findById(leadId);
    if (!lead) throw new NotFoundError('Lead não encontrado');

    if (lead.assignedLawyerId && lead.assignedLawyerId !== lawyerId) {
      throw new BadRequestError('Este lead já está sendo atendido por outro advogado');
    }

    const lawyer = await this.userRepository.findById(lawyerId);
    if (!lawyer) throw new NotFoundError('Advogado não encontrado');

    await this.leadRepository.update(leadId, { 
      assignedLawyerId: lawyerId,
      isAIPaused: true 
    });

    // Broadcast lock
    eventBus.emitLeadLocked(leadId, lead.whatsappNumber, lawyerId, lawyer.name);
  }

  async releaseFromLawyer(leadId: string): Promise<void> {
    const lead = await this.leadRepository.findById(leadId);
    if (!lead) throw new NotFoundError('Lead não encontrado');

    await this.leadRepository.update(leadId, { 
      assignedLawyerId: null,
      isAIPaused: false 
    });

    // Broadcast unlock
    eventBus.emitLeadUnlocked(leadId, lead.whatsappNumber);
  }

  async deleteLead(id: string): Promise<void> {
    const lead = await this.leadRepository.findById(id);
    if (!lead) {
      throw new NotFoundError('Lead não encontrado');
    }

    const whatsappNumber = lead.whatsappNumber;
    console.log(`[LeadService] Iniciando DELEÇÃO TOTAL do lead ${id} (WhatsApp: ${whatsappNumber})`);

    // 1. Deletar mensagens
    const msgCount = await dbRun('DELETE FROM messages WHERE whatsapp_number = $1', [whatsappNumber]);
    console.log(`[LeadService] ${msgCount} mensagens deletadas`);

    // 2. Deletar checkpoints da IA (LangGraph)
    await dbRun('DELETE FROM checkpoint_writes WHERE thread_id = $1', [whatsappNumber]);
    await dbRun('DELETE FROM checkpoint_blobs WHERE thread_id = $1', [whatsappNumber]);
    await dbRun('DELETE FROM checkpoints WHERE thread_id = $1', [whatsappNumber]);
    console.log(`[LeadService] Memória da IA limpa para o thread ${whatsappNumber}`);

    // 3. Deletar o lead
    await this.leadRepository.delete(id);
    console.log(`[LeadService] Lead ${id} removido do sistema`);
  }
}
