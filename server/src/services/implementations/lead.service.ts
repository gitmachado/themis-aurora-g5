import { ILeadService } from '../interfaces/lead.service';
import { ILeadRepository } from '../../repositories/interfaces/lead.repository';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import { IAuthService } from '../interfaces/auth.service';
import { INotificationService } from '../interfaces/notification.service';
import { ILegalProcessService } from '../interfaces/legal-process.service';
import type { Lead, User } from '@models';
import type { CreateLeadDTO, ConvertLeadDTO } from '@dtos';
import { NotFoundError, ConflictError, BadRequestError } from './errors';
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
    private readonly legalProcessService: ILegalProcessService
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

    const normalizedData: Partial<Lead> = { ...data };
    if (data.description && !data.caseDescription) {
      normalizedData.caseDescription = data.description;
    }
    delete (normalizedData as any).description;

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

    // Check if user already exists
    const existingUser = await this.userRepository.findByWhatsapp(lead.whatsappNumber);
    if (existingUser) {
      throw new ConflictError('Usuário já cadastrado com este número');
    }

    const cpf = lead.cpf?.trim() || null;
    if (cpf) {
      const existingUserByCpf = await this.userRepository.findByCpf(cpf);
      if (existingUserByCpf) {
        throw new ConflictError('Usuário já cadastrado com este CPF');
      }
    }

    const tempPassword = this.authService.generateTempPassword();
    const passwordHash = await bcrypt.hash(tempPassword, 10);

    // Create User
    const user = await this.userRepository.create({
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
        whatsapp: true
      }
    });

    // Update lead status
    const updatedLead = await this.leadRepository.update(lead.id, {
      status: 'CONVERTED',
      convertedUserId: user.id,
    });

    await this.legalProcessService.create({
      clientId: user.id,
      lawyerId: dto.lawyerId,
      title: `${lead.caseType || 'Civil'} - ${lead.name || 'Cliente'}`,
      description: lead.caseDescription || '',
      caseType: lead.caseType || 'Civil',
    });

    // Notify update via Socket
    eventBus.emitLeadUpdate(updatedLead);

    await this.notificationService.sendPush(
      user.id,
      'Seu acesso ao Themis',
      `Bem-vindo! Baixe nosso app e use a senha temporária: ${tempPassword}`
    );

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
        const error = await response.json() as any;
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
        const error = await response.json() as any;
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
