import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/network/api_client.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/notification_use_cases.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSource(ref.watch(apiClientProvider));
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
  );
});

final getMyNotificationsUseCaseProvider = Provider<GetMyNotificationsUseCase>((
  ref,
) {
  return GetMyNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsReadUseCase>((ref) {
      return MarkNotificationAsReadUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final markAllNotificationsAsReadUseCaseProvider =
    Provider<MarkAllNotificationsAsReadUseCase>((ref) {
      return MarkAllNotificationsAsReadUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final deleteNotificationUseCaseProvider = Provider<DeleteNotificationUseCase>((
  ref,
) {
  return DeleteNotificationUseCase(ref.watch(notificationRepositoryProvider));
});

final myNotificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  // Tie the cache to the logged-in account so a previous user's notifications
  // are never served to a different user after switching accounts.
  await ref.watch(currentAccountProvider.future);
  return (await ref.watch(getMyNotificationsUseCaseProvider)()).getOrThrow();
});

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref);
});

final class NotificationActions {
  final Ref _ref;

  const NotificationActions(this._ref);

  Future<void> markAsRead(String id) async {
    (await _ref.read(markNotificationAsReadUseCaseProvider)(id)).getOrThrow();
    _ref.invalidate(myNotificationsProvider);
  }

  Future<void> markAllAsRead() async {
    (await _ref.read(markAllNotificationsAsReadUseCaseProvider)()).getOrThrow();
    _ref.invalidate(myNotificationsProvider);
  }

  Future<void> delete(String id) async {
    (await _ref.read(deleteNotificationUseCaseProvider)(id)).getOrThrow();
    _ref.invalidate(myNotificationsProvider);
  }
}
