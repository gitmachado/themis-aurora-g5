import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { ITeamService } from '../interfaces/team.service';
import { ITeamRepository } from '../../repositories/interfaces/team.repository';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import type {
  CreateTeamMemberDTO,
  CreateTeamMemberResponseDTO,
  TeamMemberDTO,
} from '@dtos';
import type { User } from '@models';
import { ConflictError, NotFoundError } from './errors';

const DEFAULT_PERMISSIONS: Record<string, boolean> = {
  viewAllClients: false,
  convertLeads: true,
  manageDocuments: true,
  receiveSupportNotifications: false,
};

// Alfabeto sem 0/O/1/l/I para a senha não confundir o advogado.
const TEMP_PASSWORD_ALPHABET =
  'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';

function generateTempPassword(): string {
  const bytes = crypto.randomBytes(10);
  let out = '';
  for (const byte of bytes) {
    out += TEMP_PASSWORD_ALPHABET[byte % TEMP_PASSWORD_ALPHABET.length];
  }
  // Sufixo para satisfazer políticas que exigem dígito + caractere especial.
  return `${out}@1`;
}

export class TeamService implements ITeamService {
  constructor(
    private readonly teamRepository: ITeamRepository,
    private readonly userRepository: IUserRepository
  ) {}

  async listTeam(adminId: string): Promise<TeamMemberDTO[]> {
    const lawyers = await this.teamRepository.findByAdminId(adminId);
    return Promise.all(lawyers.map((lawyer) => this.toMemberDto(lawyer)));
  }

  async getMember(adminId: string, lawyerId: string): Promise<TeamMemberDTO> {
    const lawyer = await this.teamRepository.findOneByAdminId(adminId, lawyerId);
    if (!lawyer) {
      throw new NotFoundError('Advogado não encontrado nesta equipe');
    }
    return this.toMemberDto(lawyer);
  }

  async addMember(
    adminId: string,
    dto: CreateTeamMemberDTO
  ): Promise<CreateTeamMemberResponseDTO> {
    const existingByEmail = await this.userRepository.findByEmail(dto.email);
    if (existingByEmail) {
      throw new ConflictError('Já existe um usuário com este e-mail');
    }
    const existingByWhatsapp = await this.userRepository.findByWhatsapp(dto.whatsappNumber);
    if (existingByWhatsapp) {
      throw new ConflictError('Já existe um usuário com este WhatsApp');
    }

    // Senha temporária — devolvida UMA vez ao chefe para repassar ao advogado.
    // O advogado deve trocar no primeiro login.
    const tempPassword = generateTempPassword();
    const passwordHash = await bcrypt.hash(tempPassword, 10);

    const created = await this.userRepository.create({
      name: dto.name,
      whatsappNumber: dto.whatsappNumber,
      cpf: null,
      email: dto.email.trim().toLowerCase(),
      avatarUrl: null,
      role: 'LAWYER',
      passwordHash,
      fcmToken: null,
      notificationPreferences: { push: true, whatsapp: true },
      teamPermissions: { ...DEFAULT_PERMISSIONS },
      lawyerAdminId: adminId,
      oabNumber: dto.oabNumber,
      specialty: dto.specialty,
      mustChangePassword: true,
    });

    const member = await this.toMemberDto(created);
    return { member, tempPassword };
  }

  async updatePermissions(
    adminId: string,
    lawyerId: string,
    permissions: Record<string, boolean>
  ): Promise<TeamMemberDTO> {
    const lawyer = await this.teamRepository.findOneByAdminId(adminId, lawyerId);
    if (!lawyer) {
      throw new NotFoundError('Advogado não encontrado nesta equipe');
    }

    const merged = { ...lawyer.teamPermissions, ...permissions };
    const updated = await this.teamRepository.updatePermissions(lawyerId, merged);
    return this.toMemberDto(updated);
  }

  async removeMember(adminId: string, lawyerId: string): Promise<void> {
    const lawyer = await this.teamRepository.findOneByAdminId(adminId, lawyerId);
    if (!lawyer) {
      throw new NotFoundError('Advogado não encontrado nesta equipe');
    }

    const activeProcesses = await this.teamRepository.countActiveProcesses(lawyerId);
    if (activeProcesses > 0) {
      throw new ConflictError(
        'Não é possível remover este advogado: ele possui processos ativos. Reatribua-os antes.'
      );
    }

    await this.teamRepository.remove(lawyerId);
  }

  private async toMemberDto(user: User): Promise<TeamMemberDTO> {
    const stats = await this.teamRepository.getStats(user.id);
    return {
      id: user.id,
      name: user.name,
      email: user.email,
      whatsappNumber: user.whatsappNumber,
      avatarUrl: user.avatarUrl,
      oabNumber: user.oabNumber,
      specialty: user.specialty,
      permissions: { ...DEFAULT_PERMISSIONS, ...user.teamPermissions },
      joinedAt: user.createdAt,
      isActive: true,
      stats,
    };
  }
}
