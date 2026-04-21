import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'app_notification_button.dart';

class AppDashboardHeader extends StatelessWidget {
  final String name;
  final String greeting;
  final String? avatarUrl;
  final int notificationCount;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const AppDashboardHeader({
    super.key,
    required this.name,
    this.greeting = 'Olá,',
    this.avatarUrl,
    this.notificationCount = 0,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.secondaryLight,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        _getInitials(name),
                        style: const TextStyle(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: AppTextStyles.caption.copyWith(fontSize: 14, color: AppColors.textCaption),
                  ),
                  Text(
                    name,
                    style: AppTextStyles.h1.copyWith(fontSize: 22, color: AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppNotificationButton(
              notificationCount: notificationCount,
              onTap: onNotificationTap ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '';
  }
}
