import { ILeadService } from '../interfaces/lead.service';
import { ILeadRepository } from '../../repositories/interfaces/lead.repository';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import { IAuthService } from '../interfaces/auth.service';
import { INotificationService } from '../interfaces/notification.service';
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
    private readonly notificationService: INotificationService
  ) {}

  async createFromWhatsapp(dto: CreateLeadDTO): Promise<Lead> {
    // Check if lead already exists for this number
    const existingLead = await this.leadRepository.findByWhatsapp(dto.whatsappNumber);
    if (existingLead) {
      return this.updateLeadData(existingLead.id, dto);
    }

    return this.leadRepository.create({
      name: dto.name || null,
      whatsappNumber: dto.whatsappNumber,
      cpf: dto.cpf || null,
      caseType: dto.caseType || null,
      caseDescription: dto.caseDescription || '',
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

    return this.leadRepository.update(id, data);
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

    // Generate temporary password
    const tempPassword = this.authService.generateTempPassword();
    const passwordHash = await bcrypt.hash(tempPassword, 10);

    // Create User
    const user = await this.userRepository.create({
      name: lead.name || 'Cliente',
      whatsappNumber: lead.whatsappNumber!,
      cpf: lead.cpf || '',
      email: '', // Can be updated later
      role: 'CLIENT',
      passwordHash,
      fcmToken: null,
      notificationPreferences: {
        push: true,
        whatsapp: true
      }
    });

    // Update lead status
    await this.leadRepository.update(lead.id, { status: 'CONVERTED' });

    // Notify user with temp password (simulating WhatsApp/Email)
    await this.notificationService.sendPush(
      user.id,
      'Seu acesso ao OmniConnect',
      `Bem-vindo! Baixe nosso app e use a senha temporária: ${tempPassword}`
    );

    return user;
  }

  async getPending(): Promise<Lead[]> {
    return this.leadRepository.findPending();
  }

  async getById(id: string): Promise<Lead | null> {
    return this.leadRepository.findById(id);
  }
}
