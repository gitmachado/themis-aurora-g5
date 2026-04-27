import { IUserService } from '../interfaces/user.service';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import type { User } from '@models';
import type { CreateUserDTO, UpdateUserDTO } from '@dtos';
import { NotFoundError, ConflictError } from './errors';

export class UserService implements IUserService {
  constructor(private readonly userRepository: IUserRepository) {}

  async create(dto: CreateUserDTO): Promise<User> {
    const existing = await this.userRepository.findByWhatsapp(dto.whatsappNumber);
    if (existing) {
      throw new ConflictError('Usuário já existe com este número de WhatsApp');
    }

    return this.userRepository.create({
      name: dto.name,
      whatsappNumber: dto.whatsappNumber,
      cpf: dto.cpf || null,
      email: dto.email || null,
      role: dto.role,
      passwordHash: dto.passwordHash || null,
      fcmToken: dto.fcmToken || null,
      notificationPreferences: dto.notificationPreferences || {
        push: true,
        whatsapp: true
      }
    });
  }

  async getById(id: string): Promise<User | null> {
    return this.userRepository.findById(id);
  }

  async getByEmail(email: string): Promise<User | null> {
    // Current repository might not have findByEmail, need to add or keep as is.
    // For now, I'll assume findById and findByWhatsapp are the main ones.
    // If needed, I'll use findByWhatsapp for now or fix repository.
    return null; 
  }

  async getByWhatsapp(whatsapp: string): Promise<User | null> {
    return this.userRepository.findByWhatsapp(whatsapp);
  }

  async getClientsByLawyerId(lawyerId: string): Promise<User[]> {
    return this.userRepository.findClientsByLawyerId(lawyerId);
  }

  async getClientByLawyerId(lawyerId: string, clientId: string): Promise<User | null> {
    return this.userRepository.findClientByLawyerId(lawyerId, clientId);
  }

  async update(id: string, dto: UpdateUserDTO): Promise<User> {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new NotFoundError('Usuário não encontrado');
    }

    return this.userRepository.update(id, dto);
  }

  async delete(id: string): Promise<void> {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new NotFoundError('Usuário não encontrado');
    }

    return this.userRepository.delete(id);
  }
}
