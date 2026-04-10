import type { NotificationType } from '@enums';

export interface Notification {
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  isRead: boolean;
  extraData: Record<string, unknown> | null;
  createdAt: Date;
  updatedAt: Date;
}
