import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<List<AppNotification>> getMyNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> delete(String id);
}
