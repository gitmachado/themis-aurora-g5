import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';

class ChatListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final bool isAi;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unreadCount = 0,
    this.isAi = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isAi ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAi ? Icons.auto_awesome : Icons.headset_mic_rounded,
                  color: isAi ? AppColors.primary : AppColors.textCaption,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          time,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: unreadCount > 0 ? AppColors.primary : AppColors.textCaption,
                            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textCaption,
                              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
