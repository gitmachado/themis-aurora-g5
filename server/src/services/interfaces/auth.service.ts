import type { LoginDTO, RegisterDTO, AuthResponseDTO } from '@dtos';
import { UserRole } from '@enums';

export interface IAuthService {
  login(dto: LoginDTO): Promise<AuthResponseDTO>;
  register(dto: RegisterDTO): Promise<AuthResponseDTO>;
  generateTempPassword(): string;
  validateToken(token: string): Promise<{ userId: string; role: UserRole }>;
}
