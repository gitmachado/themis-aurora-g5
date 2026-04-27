import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/network/api_client.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSource(ref.watch(apiClientProvider));
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
  );
});

final myNotificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).getMyNotifications();
});

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref);
});

final class NotificationActions {
  final Ref _ref;

  const NotificationActions(this._ref);

  Future<void> markAsRead(String id) async {
    await _ref.read(notificationRepositoryProvider).markAsRead(id);
    _ref.invalidate(myNotificationsProvider);
  }

  Future<void> markAllAsRead() async {
    await _ref.read(notificationRepositoryProvider).markAllAsRead();
    _ref.invalidate(myNotificationsProvider);
  }

  Future<void> delete(String id) async {
    await _ref.read(notificationRepositoryProvider).delete(id);
    _ref.invalidate(myNotificationsProvider);
  }
}
