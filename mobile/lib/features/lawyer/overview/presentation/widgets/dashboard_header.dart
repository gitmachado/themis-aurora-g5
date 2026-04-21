import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String officeName;
  final int notificationCount;
  final int chatCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.officeName,
    this.notificationCount = 0,
    this.chatCount = 0,
    this.onNotificationTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                          backgroundImage: const NetworkImage(
                              'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256&h=256&auto=format&fit=crop'),
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
                  AppAppBarActions(
                    chatCount: chatCount,
                    notificationCount: notificationCount,
                    onChatTap: onChatTap ?? () => Navigator.pushNamed(context, '/lawyer-chats'),
                    onNotificationTap: onNotificationTap ?? () => Navigator.pushNamed(context, '/lawyer-notifications'),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: AppColors.divider.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
