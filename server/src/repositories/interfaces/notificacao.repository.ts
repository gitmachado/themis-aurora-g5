import type { Notificacao } from '@models';

export interface INotificacaoRepository {
  findById(id: string): Promise<Notificacao | null>;
  findByUserId(userId: string): Promise<Notificacao[]>;
  findUnreadByUserId(userId: string): Promise<Notificacao[]>;
  create(notificacao: Omit<Notificacao, 'id' | 'createdAt'>): Promise<Notificacao>;
  markAsRead(id: string): Promise<void>;
  markAllAsRead(userId: string): Promise<void>;
}
