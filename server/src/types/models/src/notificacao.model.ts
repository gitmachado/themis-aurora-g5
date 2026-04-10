import type { TipoNotificacao } from '@enums';

export interface Notificacao {
  id: string;
  userId: string;
  tipo: TipoNotificacao;
  titulo: string;
  corpo: string;
  lida: boolean;
  dadosExtras: Record<string, unknown> | null;
  createdAt: Date;
  updatedAt: Date;
}
