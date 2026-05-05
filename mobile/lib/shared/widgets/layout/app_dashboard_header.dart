import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/string_utils.dart';
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
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.yellow,
                  backgroundImage: resolvedAvatarUrl != null
                      ? NetworkImage(resolvedAvatarUrl)
                      : null,
                  child: resolvedAvatarUrl == null
                      ? Text(
                          StringUtils.getInitials(name),
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: AppTextStyles.monoFontFamily,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: AppTextStyles.tiny),
                    Text(
                      name,
                      style: AppTextStyles.h2.copyWith(fontSize: 15),
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
}
