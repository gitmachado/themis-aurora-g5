import type { UserRole } from '@enums';

export interface User {
  id: string;
  nome: string;
  whatsappNumber: string;
  cpf: string | null;
  email: string | null;
  role: UserRole;
  senhaHash: string | null;
  fcmToken: string | null;
  preferenciasNotificacao: Record<string, boolean> | null;
  createdAt: Date;
  updatedAt: Date;
}
