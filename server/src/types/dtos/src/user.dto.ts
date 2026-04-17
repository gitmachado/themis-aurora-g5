import { UserRole } from '@enums';

export interface CreateUserDTO {
  name: string;
  whatsappNumber: string;
  cpf?: string;
  email?: string;
  role: UserRole;
  passwordHash?: string;
  fcmToken?: string;
  notificationPreferences?: Record<string, boolean>;
}

export interface UpdateUserDTO {
  name?: string;
  whatsappNumber?: string;
  cpf?: string;
  email?: string;
  role?: UserRole;
  passwordHash?: string;
  fcmToken?: string;
  notificationPreferences?: Record<string, boolean>;
}

export interface UserResponseDTO {
  id: string;
  name: string;
  whatsappNumber: string;
  role: UserRole;
  email: string | null;
}
