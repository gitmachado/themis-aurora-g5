import { ILeadService } from '../interfaces/lead.service';
import { ILeadRepository } from '../../repositories/interfaces/lead.repository';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import { IAuthService } from '../interfaces/auth.service';
import { INotificationService } from '../interfaces/notification.service';
import { ILegalProcessService } from '../interfaces/legal-process.service';
import type { Lead, User } from '@models';
import type { CreateLeadDTO, ConvertLeadDTO } from '@dtos';
import { NotFoundError, ConflictError } from './errors';
import { LeadStatus, UserRole } from '@enums';
import bcrypt from 'bcryptjs';

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

    return this.leadRepository.create({
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
      lawyerNotes: null,
      discardReason: null,
    });
  }

  async updateLeadData(id: string, data: Partial<CreateLeadDTO>): Promise<Lead> {
    const lead = await this.leadRepository.findById(id);
    if (!lead) {
      throw new NotFoundError('Lead não encontrado');
    }

    const normalizedData: Partial<Lead> = { ...data };
    if (data.description && !data.caseDescription) {
      normalizedData.caseDescription = data.description;
    }
    delete (normalizedData as any).description;

    return this.leadRepository.update(id, normalizedData);
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

    const tempPassword = this.authService.generateTempPassword();
    const passwordHash = await bcrypt.hash(tempPassword, 10);

    // Create User
    const user = await this.userRepository.create({
      name: lead.name || 'Cliente',
      whatsappNumber: lead.whatsappNumber!,
      cpf: lead.cpf || '',
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
    await this.leadRepository.update(lead.id, {
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

    await this.notificationService.sendPush(
      user.id,
      'Seu acesso ao OmniConnect',
      `Bem-vindo! Baixe nosso app e use a senha temporária: ${tempPassword}`
    );

    return user;
  }

  async discard(id: string, reason?: string): Promise<Lead> {
    const lead = await this.leadRepository.findById(id);
    if (!lead) {
      throw new NotFoundError('Lead não encontrado');
    }

    return this.leadRepository.update(id, {
      status: 'DISCARDED',
      discardReason: reason || null,
    });
  }

  async getPending(): Promise<Lead[]> {
    return this.leadRepository.findPending();
  }

  async getById(id: string): Promise<Lead | null> {
    return this.leadRepository.findById(id);
  }
}
