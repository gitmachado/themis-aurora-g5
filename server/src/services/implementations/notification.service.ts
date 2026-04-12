import { INotificationService } from '../interfaces/notification.service';
import { INotificationRepository } from '../../repositories/interfaces/notification.repository';
import type { Notification } from '@models';
import type { CreateNotificationDTO } from '@dtos';
import { NotFoundError } from './errors';

export class NotificationService implements INotificationService {
  constructor(private readonly notificationRepository: INotificationRepository) {}

  async send(dto: CreateNotificationDTO): Promise<Notification> {
    const notification = await this.notificationRepository.create({
      userId: dto.userId,
      title: dto.title,
      body: dto.body,
      isRead: false,
      type: (dto as any).type || 'SYSTEM',
      extraData: (dto as any).extraData || null,
    });

    // Integrated Push Trigger
    await this.sendPush(dto.userId, dto.title, dto.body);

    return notification;
  }

  async sendPush(userId: string, title: string, body: string): Promise<void> {
    // TODO: Integrate with FCM or target service provider
    // Future: Use FCM SDK with user's fcmToken from userRepository
  }

  async getByUser(userId: string): Promise<Notification[]> {
    return this.notificationRepository.findByUserId(userId);
  }

  async getById(id: string): Promise<Notification | null> {
    return this.notificationRepository.findById(id);
  }

  async getUnread(userId: string): Promise<Notification[]> {
    return this.notificationRepository.findUnreadByUserId(userId);
  }

  async markAsRead(id: string): Promise<void> {
    const notification = await this.notificationRepository.findById(id);
    if (!notification) {
      throw new NotFoundError('Notificação não encontrada');
    }
    await this.notificationRepository.markAsRead(id);
  }

  async markAllAsRead(userId: string): Promise<void> {
    await this.notificationRepository.markAllAsRead(userId);
  }
}
