import { UserRole } from '@enums';

export interface LoginDTO {
  email: string;
  password: string;
}

export interface RegisterDTO {
  name: string;
  whatsappNumber: string;
  cpf: string;
  email: string;
  password: string;
}

export interface AuthResponseDTO {
  token: string | null;
  userId: string;
  role: UserRole;
  requiresEmailConfirmation?: boolean;
}
