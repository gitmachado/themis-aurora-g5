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
import { ISupabaseAuthService } from '../interfaces/supabase-auth.service';

export class LeadService implements ILeadService {
  constructor(
    private readonly leadRepository: ILeadRepository,
    private readonly userRepository: IUserRepository,
    private readonly authService: IAuthService,
    private readonly notificationService: INotificationService,
    private readonly legalProcessService: ILegalProcessService,
    private readonly supabaseAuthService?: ISupabaseAuthService
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

    const shouldInviteByEmail = Boolean(
      lead.email && this.supabaseAuthService?.isAdminAuthConfigured()
    );
    const tempPassword = shouldInviteByEmail ? null : this.authService.generateTempPassword();
    const passwordHash = tempPassword ? await bcrypt.hash(tempPassword, 10) : null;

    // Create User
    const user = await this.userRepository.create({
      name: lead.name || 'Cliente',
      whatsappNumber: lead.whatsappNumber!,
      cpf: lead.cpf || '',
      email: lead.email || '',
      supabaseUserId: null,
      avatarUrl: null,
      role: 'CLIENT',
      passwordHash,
      fcmToken: null,
      notificationPreferences: {
        push: true,
        whatsapp: true
      }
    });

    let convertedUser = user;
    try {
      if (shouldInviteByEmail && lead.email) {
        const supabaseUser = await this.supabaseAuthService!.inviteUserByEmail({
          email: lead.email,
          name: user.name,
          role: 'CLIENT',
          localUserId: user.id,
          whatsappNumber: user.whatsappNumber,
          cpf: user.cpf,
        });
        convertedUser = await this.userRepository.update(user.id, {
          supabaseUserId: supabaseUser.supabaseUserId,
        });
      }
    } catch (error) {
      await this.userRepository.delete(user.id);
      throw error;
    }

    // Update lead status
    await this.leadRepository.update(lead.id, {
      status: 'CONVERTED',
      convertedUserId: convertedUser.id,
    });

    await this.legalProcessService.create({
      clientId: convertedUser.id,
      lawyerId: dto.lawyerId,
      title: `${lead.caseType || 'Civil'} - ${lead.name || 'Cliente'}`,
      description: lead.caseDescription || '',
      caseType: lead.caseType || 'Civil',
    });

    const accessMessage = shouldInviteByEmail
      ? 'Bem-vindo! Enviamos um convite para o seu email para ativar o acesso ao OmniConnect.'
      : `Bem-vindo! Baixe nosso app e use a senha temporária: ${tempPassword}`;

    await this.notificationService.sendPush(
      convertedUser.id,
      'Seu acesso ao OmniConnect',
      accessMessage
    );

    return convertedUser;
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
