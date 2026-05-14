import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../constants/app_colors.dart';
import 'layout/app_notification_button.dart';

class AppAppBarActions extends ConsumerWidget {
  final int? notificationCount;
  final int? chatCount;
  final bool showChat;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;
  final Color? badgeColor;

  const AppAppBarActions({
    super.key,
    this.notificationCount,
    this.chatCount,
    this.showChat = true,
    this.onNotificationTap,
    this.onChatTap,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int unreadCount =
        notificationCount ?? ref.watch(unreadNotificationsCountProvider);
    final int handoffCount =
        chatCount ?? ref.watch(handoffNotificationsCountProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showChat)
          _buildActionIcon(
            context,
            icon: Icons.chat_bubble_outline_rounded,
            count: handoffCount,
            onTap:
                onChatTap ??
                () => Navigator.pushNamed(context, '/lawyer-chats'),
          ),
        const SizedBox(width: 8),
        AppNotificationButton(
          notificationCount: unreadCount,
          onTap:
              onNotificationTap ??
              () {
                final route = showChat
                    ? '/lawyer-notifications'
                    : '/notifications';
                Navigator.pushNamed(context, route);
              },
          size: 22,
          badgeColor: badgeColor,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildActionIcon(
    BuildContext context, {
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            icon: Icon(icon, color: AppColors.ink2, size: 20),
            onPressed: onTap,
            padding: EdgeInsets.zero,
          ),
        ),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.yellow,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                count > 9 ? '+9' : count.toString(),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
