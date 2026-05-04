import { INotificationService } from '../interfaces/notification.service';
import { INotificationRepository } from '../../repositories/interfaces/notification.repository';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import { PushNotificationService } from '../notifications/push_notification_service';
import type { Notification } from '@models';
import type { CreateNotificationDTO } from '@dtos';
import { NotFoundError } from './errors';
import { eventBus } from '../communication/InternalEventBus';

export class NotificationService implements INotificationService {
  constructor(
    private readonly notificationRepository: INotificationRepository,
    private readonly userRepository: IUserRepository,
    private readonly pushNotificationService: PushNotificationService
  ) {}

  async send(dto: CreateNotificationDTO): Promise<Notification> {
    const notification = await this.notificationRepository.create({
      userId: dto.userId,
      title: dto.title,
      body: dto.body,
      isRead: false,
      type: (dto as any).type || 'SYSTEM',
      extraData: (dto as any).extraData || null,
    });

    // Notify via Socket.io
    eventBus.emitNotification(dto.userId, notification);

    // Integrated Push Trigger
    await this.sendPush(dto.userId, dto.title, dto.body);

    return notification;
  }

  async sendPush(userId: string, title: string, body: string): Promise<void> {
    try {
      const user = await this.userRepository.findById(userId);
      if (!user || !user.fcmToken) {
        return;
      }

      await this.pushNotificationService.sendPushNotification({
        token: user.fcmToken,
        title,
        body,
      });
    } catch (error) {
      console.error('[NotificationService] Error sending push notification:', error);
    }
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

  async delete(id: string): Promise<void> {
    const notification = await this.notificationRepository.findById(id);
    if (!notification) {
      throw new NotFoundError('Notificação não encontrada');
    }

    await this.notificationRepository.delete(id);
  }
}
