import type { UserRole } from '@enums';

export interface User {
  id: string;
  name: string;
  whatsappNumber: string;
  cpf: string | null;
  email: string | null;
  role: UserRole;
  passwordHash: string | null;
  fcmToken: string | null;
  notificationPreferences: Record<string, boolean> | null;
  createdAt: Date;
  updatedAt: Date;
}
