import { INotificationRepository } from '../interfaces/notification.repository';
import type { Notification } from '@models';
import { dbGet, dbAll, dbRun } from '../../config/database';

export class NotificationRepository implements INotificationRepository {
  private readonly selectFields = `
    id, 
    user_id as "userId", 
    type, 
    title, 
    body, 
    is_read as "isRead", 
    extra_data as "extraData", 
    created_at as "createdAt", 
    updated_at as "updatedAt"
  `;

  async findById(id: string): Promise<Notification | null> {
    return dbGet<Notification>(`SELECT ${this.selectFields} FROM notifications WHERE id = $1`, [id]);
  }

  async findByUserId(userId: string): Promise<Notification[]> {
    return dbAll<Notification>(`SELECT ${this.selectFields} FROM notifications WHERE user_id = $1`, [userId]);
  }

  async findUnreadByUserId(userId: string): Promise<Notification[]> {
    return dbAll<Notification>(`SELECT ${this.selectFields} FROM notifications WHERE user_id = $1 AND is_read = FALSE`, [userId]);
  }

  async create(notification: Omit<Notification, 'id' | 'createdAt' | 'updatedAt'>): Promise<Notification> {
    return (await dbGet<Notification>(
      `INSERT INTO notifications (user_id, type, title, body, is_read, extra_data)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING ${this.selectFields}`,
      [notification.userId, notification.type, notification.title, notification.body, notification.isRead, notification.extraData]
    ))!;
  }

  async markAsRead(id: string): Promise<void> {
    await dbRun('UPDATE notifications SET is_read = TRUE WHERE id = $1', [id]);
  }

  async markAllAsRead(userId: string): Promise<void> {
    await dbRun('UPDATE notifications SET is_read = TRUE WHERE user_id = $1', [userId]);
  }
}
