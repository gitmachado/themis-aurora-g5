import { UserRole } from '@enums';

export interface CreateUserDTO {
  name: string;
  whatsappNumber: string;
  cpf?: string;
  email?: string;
  supabaseUserId?: string | null;
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
  supabaseUserId?: string | null;
  role?: UserRole;
  passwordHash?: string;
  fcmToken?: string;
  notificationPreferences?: Record<string, boolean>;
}

export interface UserResponseDTO {
  id: string;
  name: string;
  whatsappNumber: string;
  cpf: string | null;
  role: UserRole;
  email: string | null;
  supabaseUserId: string | null;
}

export interface AccountResponseDTO {
  id: string;
  name: string;
  whatsappNumber: string;
  cpf: string | null;
  email: string | null;
  supabaseUserId: string | null;
  role: UserRole;
  notificationPreferences: Record<string, boolean> | null;
  createdAt: Date;
  updatedAt: Date;
}
