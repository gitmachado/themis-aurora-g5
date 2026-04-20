import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
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
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_outlined, size: 28, color: AppColors.primary),
                  onPressed: onNotificationTap,
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      notificationCount > 9 ? '9+' : notificationCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
