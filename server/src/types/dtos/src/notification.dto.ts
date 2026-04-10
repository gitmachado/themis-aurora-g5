import type { NotificationType } from '@enums';

export interface CreateNotificationDTO {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  extraData?: Record<string, unknown>;
}
