import type { LoginDTO, RegisterDTO, AuthResponseDTO } from '@dtos';

export interface IAuthService {
  login(dto: LoginDTO): Promise<AuthResponseDTO>;
  register(dto: RegisterDTO): Promise<AuthResponseDTO>;
  generateTempPassword(): string;
  validateToken(token: string): Promise<{ userId: string; role: string }>;
}
