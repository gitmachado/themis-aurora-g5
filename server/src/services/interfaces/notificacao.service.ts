import type { Notificacao } from '@models';
import type { CreateNotificacaoDTO } from '@dtos';

export interface INotificacaoService {
  send(dto: CreateNotificacaoDTO): Promise<Notificacao>;
  sendPush(userId: string, titulo: string, corpo: string): Promise<void>;
  getByUser(userId: string): Promise<Notificacao[]>;
  getUnread(userId: string): Promise<Notificacao[]>;
  markAsRead(id: string): Promise<void>;
  markAllAsRead(userId: string): Promise<void>;
}
