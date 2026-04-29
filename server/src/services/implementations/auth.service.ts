import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { IAuthService } from '../interfaces/auth.service';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import type { LoginDTO, RegisterDTO, AuthResponseDTO } from '@dtos';
import { UnauthorizedError, ConflictError } from './errors';
import { UserRole } from '@enums';
import { getJwtSecret } from '../../config/runtime';
import {
  ISupabaseAuthService,
  SupabaseAuthUserResult,
} from '../interfaces/supabase-auth.service';

export class AuthService implements IAuthService {
  private readonly jwtSecret: string;
  private readonly jwtExpiresIn: string;

  constructor(
    private readonly userRepository: IUserRepository,
    private readonly supabaseAuthService?: ISupabaseAuthService
  ) {
    this.jwtSecret = getJwtSecret();
    this.jwtExpiresIn = process.env.JWT_EXPIRE_IN || '7d';
  }

  async login(dto: LoginDTO): Promise<AuthResponseDTO> {
    const email = dto.email.trim().toLowerCase();
    const supabaseResult = await this.trySupabasePasswordSignIn(
      email,
      dto.password
    );

    const user = supabaseResult
      ? await this.userRepository.findBySupabaseUserId(supabaseResult.supabaseUserId)
        || await this.userRepository.findByEmail(email)
      : await this.userRepository.findByEmail(email);

    if (!user) {
      throw new UnauthorizedError('Credenciais inválidas');
    }

    if (!supabaseResult) {
      if (!user.passwordHash) {
        throw new UnauthorizedError('Credenciais inválidas');
      }

      const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
      if (!isPasswordValid) {
        throw new UnauthorizedError('Credenciais inválidas');
      }
    } else if (!user.supabaseUserId) {
      await this.userRepository.update(user.id, { supabaseUserId: supabaseResult.supabaseUserId });
    }

    return {
      token: this.generateToken(user.id, user.role),
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

    if (dto.email) {
      const existingEmail = await this.userRepository.findByEmail(dto.email);
      if (existingEmail) {
        throw new ConflictError('Email já cadastrado');
      }
    }

    let supabaseUserId: string | null = null;
    let passwordHash: string | null = await bcrypt.hash(dto.password, 10);
    let requiresEmailConfirmation = false;

    if (dto.email && this.supabaseAuthService?.isPasswordAuthConfigured()) {
      const supabaseResult = await this.supabaseAuthService.signUpWithPassword({
        email: dto.email,
        password: dto.password,
        name: dto.name,
        role: 'CLIENT',
        whatsappNumber: dto.whatsappNumber,
        cpf: dto.cpf,
      });
      supabaseUserId = supabaseResult.supabaseUserId;
      passwordHash = null;
      requiresEmailConfirmation = !supabaseResult.accessToken;
    }

    const user = await this.userRepository.create({
      name: dto.name,
      whatsappNumber: dto.whatsappNumber,
      cpf: dto.cpf,
      email: dto.email || '',
      supabaseUserId,
      avatarUrl: null,
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
      token: requiresEmailConfirmation ? null : token,
      userId: user.id,
      role: user.role,
      requiresEmailConfirmation,
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

  private async trySupabasePasswordSignIn(
    email: string,
    password: string
  ): Promise<SupabaseAuthUserResult | null> {
    if (!this.supabaseAuthService?.isPasswordAuthConfigured()) {
      return null;
    }

    try {
      return await this.supabaseAuthService.signInWithPassword({
        email,
        password,
      });
    } catch (error) {
      if (error instanceof UnauthorizedError) {
        return null;
      }

      throw error;
    }
  }
}
