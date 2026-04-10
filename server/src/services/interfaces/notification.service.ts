import type { Notification } from '@models';
import type { CreateNotificationDTO } from '@dtos';

export interface INotificationService {
  send(dto: CreateNotificationDTO): Promise<Notification>;
  sendPush(userId: string, title: string, body: string): Promise<void>;
  getByUser(userId: string): Promise<Notification[]>;
  getUnread(userId: string): Promise<Notification[]>;
  markAsRead(id: string): Promise<void>;
  markAllAsRead(userId: string): Promise<void>;
}
