import { UserRole } from '@enums';

export interface CreateUserDTO {
  name: string;
  whatsappNumber: string;
  cpf?: string;
  email?: string;
  avatarUrl?: string | null;
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
  avatarUrl?: string | null;
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
  avatarUrl?: string | null;
}

export interface AccountResponseDTO {
  id: string;
  name: string;
  whatsappNumber: string;
  cpf: string | null;
  email: string | null;
  avatarUrl: string | null;
  role: UserRole;
  notificationPreferences: Record<string, boolean> | null;
  teamPermissions: Record<string, boolean>;
  lawyerAdminId: string | null;
  mustChangePassword: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface ChangePasswordDTO {
  newPassword: string;
  currentPassword?: string;
}
