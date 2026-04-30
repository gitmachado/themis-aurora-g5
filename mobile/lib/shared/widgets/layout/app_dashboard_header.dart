import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../app_app_bar_actions.dart';

class AppDashboardHeader extends StatelessWidget {
  final String name;
  final String greeting;
  final String? subtitle;
  final String? avatarUrl;
  final int notificationCount;
  final int chatCount;
  final bool showChat;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;

  const AppDashboardHeader({
    super.key,
    required this.name,
    this.greeting = 'Olá,',
    this.subtitle,
    this.avatarUrl,
    this.notificationCount = 0,
    this.chatCount = 0,
    this.showChat = false,
    this.onProfileTap,
    this.onNotificationTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedAvatarUrl = avatarUrl?.isNotEmpty == true ? avatarUrl : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.secondaryLight,
                  backgroundImage: resolvedAvatarUrl != null
                      ? NetworkImage(resolvedAvatarUrl)
                      : null,
                  child: resolvedAvatarUrl == null
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
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 14,
                        color: AppColors.textCaption,
                      ),
                    ),
                    Text(
                      name,
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textCaption,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppAppBarActions(
                notificationCount: notificationCount,
                chatCount: chatCount,
                showChat: showChat,
                onNotificationTap: onNotificationTap,
                onChatTap: onChatTap,
              ),
            ],
          ),
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
