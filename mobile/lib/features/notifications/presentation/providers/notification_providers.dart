import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';
import '../../../../shared/network/websocket_client.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/network/api_client.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/notification_use_cases.dart';
import '../../data/models/app_notification_model.dart';

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

final deleteManyNotificationsUseCaseProvider =
    Provider<DeleteManyNotificationsUseCase>((ref) {
      return DeleteManyNotificationsUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final myNotificationsProvider =
    AsyncNotifierProvider<MyNotificationsNotifier, List<AppNotification>>(
      MyNotificationsNotifier.new,
    );

class MyNotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  StreamSubscription? _subscription;

  @override
  Future<List<AppNotification>> build() async {
    // Tie the cache to the logged-in account so a previous user's notifications
    // are never served to a different user after switching accounts.
    await ref.watch(currentAccountProvider.future);

    _listenToEvents();
    ref.onDispose(() => _subscription?.cancel());
    return _fetch();
  }

  void _listenToEvents() {
    _subscription?.cancel();
    _subscription = ref.watch(webSocketClientProvider).events.listen((event) {
      if (event.type == 'notification:new') {
        final notification = AppNotificationModel.fromJson(event.data);
        state = AsyncData([notification, ...state.value ?? []]);
      } else if (event.type == 'connected') {
        refresh(); // Refresh on reconnection to ensure no lost notifications
      }
    });
  }

  Future<List<AppNotification>> _fetch() async {
    return (await ref.read(getMyNotificationsUseCaseProvider)()).getOrThrow();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }
}

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref);
});

final class NotificationActions {
  final Ref _ref;

  const NotificationActions(this._ref);

  Future<void> markAsRead(String id) async {
    (await _ref.read(markNotificationAsReadUseCaseProvider)(id)).getOrThrow();
    await _ref.read(myNotificationsProvider.notifier).refresh();
  }

  Future<void> markAllAsRead() async {
    (await _ref.read(markAllNotificationsAsReadUseCaseProvider)()).getOrThrow();
    await _ref.read(myNotificationsProvider.notifier).refresh();
  }

  Future<void> delete(String id) async {
    (await _ref.read(deleteNotificationUseCaseProvider)(id)).getOrThrow();
    await _ref.read(myNotificationsProvider.notifier).refresh();
  }

  Future<void> deleteMany(List<String> ids) async {
    (await _ref.read(deleteManyNotificationsUseCaseProvider)(ids)).getOrThrow();
    await _ref.read(myNotificationsProvider.notifier).refresh();
  }
}

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(myNotificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

final handoffNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(myNotificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => n.type == 'HUMAN_SUPPORT' && !n.isRead).length;
});
