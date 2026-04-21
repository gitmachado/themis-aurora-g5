import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXS),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.chatBubbleMe : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppDimensions.radiusL),
            topRight: const Radius.circular(AppDimensions.radiusL),
            bottomLeft: isMe ? const Radius.circular(AppDimensions.radiusL) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(AppDimensions.radiusL),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
                if (isMe) ...[
                  const SizedBox(width: AppDimensions.spacingXS),
                  const Icon(Icons.done_all, size: AppDimensions.iconXS, color: AppColors.primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
