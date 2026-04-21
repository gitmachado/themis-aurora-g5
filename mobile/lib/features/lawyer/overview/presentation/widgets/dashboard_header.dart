import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/app_notification_button.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String officeName;
  final int notificationCount;
  final int chatCount;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.officeName,
    this.notificationCount = 0,
    this.chatCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256&h=256&auto=format&fit=crop'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, $userName',
                        style: AppTextStyles.h2.copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        officeName,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textCaption,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildIconButton(
            context,
            icon: Icons.chat_bubble_outline_rounded,
            count: chatCount,
            onTap: () => Navigator.pushNamed(context, '/lawyer-chats'),
          ),
          const SizedBox(width: 8),
          AppNotificationButton(
            notificationCount: notificationCount,
            onTap: () => Navigator.pushNamed(context, '/lawyer-notifications'),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, {required IconData icon, required int count, required VoidCallback onTap}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          ),
          child: IconButton(
            icon: Icon(icon, size: 22, color: AppColors.textPrimary),
            onPressed: onTap,
          ),
        ),
        if (count > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 9 ? '+9' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return parts[0].toUpperCase();
  }
}
