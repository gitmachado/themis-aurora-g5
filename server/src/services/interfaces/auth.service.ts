import type { LoginDTO, RegisterDTO, AuthResponseDTO } from '@dtos';
import { UserRole } from '@enums';

export interface IAuthService {
  login(dto: LoginDTO): Promise<AuthResponseDTO>;
  register(dto: RegisterDTO): Promise<AuthResponseDTO>;
  googleSignIn(idToken: string): Promise<AuthResponseDTO>;
  generateTempPassword(): string;
  validateToken(token: string): Promise<{ userId: string; role: UserRole }>;
  /**
   * Clears server-side session state for the user: FCM token is wiped so
   * that pending pushes will no longer reach the device of someone who
   * logged out (G5-75).
   */
  logout(userId: string): Promise<void>;
}
