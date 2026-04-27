import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

final class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  const NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AppNotification>> getMyNotifications() {
    return _remoteDataSource.getMyNotifications();
  }

  @override
  Future<void> markAsRead(String id) => _remoteDataSource.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _remoteDataSource.markAllAsRead();

  @override
  Future<void> delete(String id) => _remoteDataSource.delete(id);
}
