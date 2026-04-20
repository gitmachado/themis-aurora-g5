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
    required this.unreadCount,
    required this.isAi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
                  color: isAi ? const Color(0xFFE8EAF6) : const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAi ? Icons.smart_toy_outlined : Icons.chat_bubble_outline,
                  color: const Color(0xFF1A237E),
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
                            fontWeight: isAi ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 16,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isAi ? FontWeight.w600 : FontWeight.normal,
                            color: isAi ? const Color(0xFF1A237E) : const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A237E),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
