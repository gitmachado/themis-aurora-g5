import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { IAuthService } from '../interfaces/auth.service';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import type { LoginDTO, RegisterDTO, AuthResponseDTO } from '@dtos';
import { UnauthorizedError, ConflictError, ValidationError } from './errors';
import { UserRole } from '@enums';

export class AuthService implements IAuthService {
  private readonly jwtSecret: string;
  private readonly jwtExpiresIn: string;

  constructor(private readonly userRepository: IUserRepository) {
    this.jwtSecret = process.env.JWT_SECRET || 'super-secret-key-change-me';
    this.jwtExpiresIn = process.env.JWT_EXPIRE_IN || '7d';
  }

  async login(dto: LoginDTO): Promise<AuthResponseDTO> {
    const user = await this.userRepository.findByWhatsapp(dto.whatsappNumber);

    if (!user || !user.passwordHash) {
      throw new UnauthorizedError('Credenciais inválidas');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);

    if (!isPasswordValid) {
      throw new UnauthorizedError('Credenciais inválidas');
    }

    const token = this.generateToken(user.id, user.role);

    return {
      token,
      userId: user.id,
      role: user.role,
    };
  }

  async register(dto: RegisterDTO): Promise<AuthResponseDTO> {
    const existingUser = await this.userRepository.findByWhatsapp(dto.whatsappNumber);
    if (existingUser) {
      throw new ConflictError('Número de WhatsApp já cadastrado');
    }

    const existingCpf = await this.userRepository.findByCpf(dto.cpf);
    if (existingCpf) {
      throw new ConflictError('CPF já cadastrado');
    }

    const passwordHash = await bcrypt.hash(dto.password, 10);

    const user = await this.userRepository.create({
      name: dto.name,
      whatsappNumber: dto.whatsappNumber,
      cpf: dto.cpf,
      email: '', // Default empty
      role: 'CLIENT',
      passwordHash,
      fcmToken: null,
      notificationPreferences: {
        push: true,
        whatsapp: true
      }
    });

    const token = this.generateToken(user.id, user.role);

    return {
      token,
      userId: user.id,
      role: user.role,
    };
  }

  generateTempPassword(): string {
    return Math.random().toString(36).slice(-8).toUpperCase();
  }

  async validateToken(token: string): Promise<{ userId: string; role: UserRole }> {
    try {
      const decoded = jwt.verify(token, this.jwtSecret) as { sub: string; role: UserRole };
      return {
        userId: decoded.sub,
        role: decoded.role,
      };
    } catch (error) {
      throw new UnauthorizedError('Token inválido ou expirado');
    }
  }

  private generateToken(userId: string, role: UserRole): string {
    return jwt.sign({ role }, this.jwtSecret, {
      subject: userId,
      expiresIn: this.jwtExpiresIn as any,
    });
  }
}
