import { UserRole } from '@enums';

export interface LoginDTO {
  identifier?: string;
  whatsappNumber?: string;
  cpf?: string;
  password: string;
}

export interface RegisterDTO {
  name: string;
  whatsappNumber: string;
  cpf: string;
  password: string;
}

export interface AuthResponseDTO {
  token: string;
  userId: string;
  role: UserRole;
}
