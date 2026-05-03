import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../features/notifications/domain/entities/app_notification.dart';
import '../../../../../../features/notifications/presentation/notification_display.dart';
import '../../../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/cards/app_notification_tile.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class ClientNotificationsScreen extends ConsumerStatefulWidget {
  const ClientNotificationsScreen({super.key});

  @override
  ConsumerState<ClientNotificationsScreen> createState() =>
      _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState
    extends ConsumerState<ClientNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(myNotificationsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Notificações',
          showBackButton: true,
          actions: [
            TextButton(
              onPressed: () =>
                  ref.read(notificationActionsProvider).markAllAsRead(),
              child: const Text(
                'Limpar',
                style: TextStyle(color: AppColors.ink),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Não lidas'),
              Tab(text: 'Todas'),
            ],
            labelColor: AppColors.ink,
            unselectedLabelColor: AppColors.textCaption,
            indicatorColor: AppColors.yellow,
            indicatorWeight: 3,
          ),
        ),
        body: SafeArea(
          top: false,
          child: notifications.when(
            data: (data) => TabBarView(
              children: [
                _buildNotificationList(data, onlyUnread: true),
                _buildNotificationList(data, onlyUnread: false),
              ],
            ),
            loading: _buildLoadingList,
            error: (error, _) => _buildErrorState(error),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<AppNotification> notifications, {
    required bool onlyUnread,
  }) {
    final list = onlyUnread
        ? notifications.where((n) => !n.isRead).toList()
        : notifications;

    if (list.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final n = list[index];
        return AppNotificationTile(
          id: n.id,
          title: n.title,
          body: n.body,
          time: n.timeLabel,
          type: n.tileType,
          isRead: n.isRead,
          onToggleRead: _toggleReadStatus,
          onDelete: _deleteNotification,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: AppColors.textCaption.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma notificação por aqui',
            style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReadStatus(String id) async {
    await ref.read(notificationActionsProvider).markAsRead(id);
  }

  Future<void> _deleteNotification(String id) async {
    await ref.read(notificationActionsProvider).delete(id);
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 72, borderRadius: 12),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}
