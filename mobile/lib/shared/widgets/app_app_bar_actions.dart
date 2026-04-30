import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'layout/app_notification_button.dart';

class AppAppBarActions extends StatelessWidget {
  final int notificationCount;
  final int chatCount;
  final bool showChat;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;

  const AppAppBarActions({
    super.key,
    this.notificationCount = 0,
    this.chatCount = 0,
    this.showChat = true,
    this.onNotificationTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showChat)
          _buildActionIcon(
            context,
            icon: Icons.chat_bubble_outline_rounded,
            count: chatCount,
            onTap:
                onChatTap ??
                () => Navigator.pushNamed(context, '/lawyer-chats'),
          ),
        AppNotificationButton(
          notificationCount: notificationCount,
          onTap:
              onNotificationTap ??
              () {
                final route = showChat
                    ? '/lawyer-notifications'
                    : '/notifications';
                Navigator.pushNamed(context, route);
              },
          size: 22,
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
        IconButton(
          icon: Icon(icon, color: AppColors.primary, size: 22),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                count > 9 ? '+9' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
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
