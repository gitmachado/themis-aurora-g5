import type { Notification } from '@models';
import type { CreateNotificationDTO } from '@dtos';

export interface INotificationService {
  /**
   * Persists a notification, broadcasts via Socket.io and fires a push.
   * Returns `null` when the dispatch is skipped — e.g. the target user
   * does not exist, or the notification type is not allowed for their role.
   * Notifications are best-effort side-effects, so callers should not
   * fail their primary flow when delivery is skipped.
   */
  send(dto: CreateNotificationDTO): Promise<Notification | null>;
  sendPush(userId: string, title: string, body: string): Promise<void>;
  getById(id: string): Promise<Notification | null>;
  getByUser(userId: string): Promise<Notification[]>;
  getUnread(userId: string): Promise<Notification[]>;
  markAsRead(id: string): Promise<void>;
  markAllAsRead(userId: string): Promise<void>;
  delete(id: string): Promise<void>;
  deleteMany(ids: string[], userId: string): Promise<void>;
}
