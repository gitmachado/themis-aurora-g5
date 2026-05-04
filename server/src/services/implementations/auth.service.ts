import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { OAuth2Client } from 'google-auth-library';
import { IAuthService } from '../interfaces/auth.service';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import type { LoginDTO, RegisterDTO, AuthResponseDTO } from '@dtos';
import { UnauthorizedError, ConflictError } from './errors';
import { UserRole } from '@enums';
import { getJwtSecret } from '../../config/runtime';

export class AuthService implements IAuthService {
  private readonly jwtSecret: string;
  private readonly jwtExpiresIn: string;
  private readonly googleClient: OAuth2Client;

  constructor(private readonly userRepository: IUserRepository) {
    this.jwtSecret = getJwtSecret();
    this.jwtExpiresIn = process.env.JWT_EXPIRE_IN || '7d';
    
    this.googleClient = new OAuth2Client(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET
    );
  }

  async login(dto: LoginDTO): Promise<AuthResponseDTO> {
    const email = dto.email.trim().toLowerCase();
    const user = await this.userRepository.findByEmail(email);

    if (!user) {
      throw new UnauthorizedError('Credenciais inválidas');
    }

    if (!user.passwordHash) {
      throw new UnauthorizedError('Credenciais inválidas');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedError('Credenciais inválidas');
    }

    return {
      token: this.generateToken(user.id, user.role),
      userId: user.id,
      role: user.role,
    };
  }

  async register(dto: RegisterDTO): Promise<AuthResponseDTO> {
    const email = dto.email.trim().toLowerCase();
    const existingUser = await this.userRepository.findByWhatsapp(dto.whatsappNumber);
    if (existingUser) {
      throw new ConflictError('Número de WhatsApp já cadastrado');
    }

    const existingCpf = await this.userRepository.findByCpf(dto.cpf);
    if (existingCpf) {
      throw new ConflictError('CPF já cadastrado');
    }

    const existingEmail = await this.userRepository.findByEmail(email);
    if (existingEmail) {
      throw new ConflictError('Email já cadastrado');
    }

    const passwordHash = await bcrypt.hash(dto.password, 10);

    const user = await this.userRepository.create({
      name: dto.name,
      whatsappNumber: dto.whatsappNumber,
      cpf: dto.cpf,
      email,
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
      token,
      userId: user.id,
      role: user.role,
    };
  }

  generateTempPassword(): string {
    return Math.random().toString(36).slice(-8).toUpperCase();
  }

  async googleSignIn(idToken: string): Promise<AuthResponseDTO> {
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken,
        audience: [
          process.env.GOOGLE_CLIENT_ID!,
          process.env.GOOGLE_ANDROID_CLIENT_ID!,
        ],
      });
      const payload = ticket.getPayload();
      
      if (!payload || !payload.email) {
        throw new UnauthorizedError('Token Google inválido ou sem email');
      }

      const email = payload.email.trim().toLowerCase();
      const user = await this.userRepository.findByEmail(email);

      if (!user) {
        throw new UnauthorizedError('Usuário não cadastrado. Registre-se primeiro.');
      }

      return {
        token: this.generateToken(user.id, user.role),
        userId: user.id,
        role: user.role,
      };
    } catch (error) {
      console.error('[Google Auth Error]:', error);
      if (error instanceof UnauthorizedError) {
        throw error;
      }
      throw new UnauthorizedError('Falha ao validar token Google');
    }
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
