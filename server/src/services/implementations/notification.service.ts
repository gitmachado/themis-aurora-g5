import { INotificationService } from '../interfaces/notification.service';
import { INotificationRepository } from '../../repositories/interfaces/notification.repository';
import { IUserRepository } from '../../repositories/interfaces/user.repository';
import { PushNotificationService } from '../notifications/push_notification_service';
import type { Notification } from '@models';
import type { CreateNotificationDTO } from '@dtos';
import { NotFoundError } from './errors';
import { eventBus } from '../communication/InternalEventBus';
import { isRoleAllowedForNotificationType } from './notification-routing';

export class NotificationService implements INotificationService {
  constructor(
    private readonly notificationRepository: INotificationRepository,
    private readonly userRepository: IUserRepository,
    private readonly pushNotificationService: PushNotificationService
  ) {}

  async send(dto: CreateNotificationDTO): Promise<Notification | null> {
    // G5-75: never dispatch to a user that does not exist — protects against
    // bot/AI/legacy flows that may have stale userIds in their state.
    const targetUser = await this.userRepository.findById(dto.userId);
    if (!targetUser) {
      console.warn(
        `[NotificationService] Skipping notification for unknown user "${dto.userId}" (type=${dto.type || 'SYSTEM'})`
      );
      return null;
    }

    // G5-75: enforce role-based routing so push alerts intended for lawyers
    // (NEW_LEAD, HUMAN_SUPPORT, DOCUMENT_SENT) never reach clients and vice-versa.
    if (!isRoleAllowedForNotificationType(dto.type, targetUser.role)) {
      console.warn(
        `[NotificationService] Blocked routing of "${dto.type}" to ${targetUser.role} user "${dto.userId}"`
      );
      return null;
    }

    const notification = await this.notificationRepository.create({
      userId: dto.userId,
      title: dto.title,
      body: dto.body,
      isRead: false,
      type: dto.type || 'SYSTEM',
      extraData: dto.extraData || null,
    });

    // Notify via Socket.io
    eventBus.emitNotification(dto.userId, notification);

    // Integrated Push Trigger (passes the already-loaded user to avoid a second lookup)
    await this.sendPushToUser(targetUser, dto.title, dto.body);

    return notification;
  }

  private async sendPushToUser(
    user: { fcmToken: string | null },
    title: string,
    body: string
  ): Promise<void> {
    if (!user.fcmToken) return;
    try {
      await this.pushNotificationService.sendPushNotification({
        token: user.fcmToken,
        title,
        body,
      });
    } catch (error) {
      console.error('[NotificationService] Error sending push notification:', error);
    }
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

  async deleteMany(ids: string[], userId: string): Promise<void> {
    await this.notificationRepository.deleteMany(ids, userId);
  }
}
