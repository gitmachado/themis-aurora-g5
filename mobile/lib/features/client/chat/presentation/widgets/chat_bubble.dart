import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final String sender; // 'CLIENT', 'LAWYER', 'BOT'
  final bool isMe;
  final bool isInverted;

  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.sender,
    required this.isMe,
    this.isInverted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isBot = sender == 'BOT';
    final isLawyer = sender == 'LAWYER';
    final isClient = sender == 'CLIENT';

    // Cores baseadas no design do chat de advogado
    Color backgroundColor;
    Color textColor;
    Color? borderColor;

    if (isLawyer) {
      backgroundColor = isInverted ? AppColors.white : AppColors.ink;
      textColor = isInverted ? AppColors.ink : AppColors.white;
      borderColor = isInverted ? AppColors.line : null;
    } else if (isBot) {
      backgroundColor = AppColors.yellowSoft;
      textColor = AppColors.ink;
      borderColor = null;
    } else {
      // Client
      backgroundColor = isInverted ? AppColors.ink : AppColors.white;
      textColor = isInverted ? AppColors.white : AppColors.ink;
      borderColor = isInverted ? null : AppColors.line;
    }

    final isDark = (isLawyer && !isInverted) || (isClient && isInverted);
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.ink3;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label de quem enviou (estilo advogado)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                isBot ? 'THEMIS AI' : (isLawyer ? 'ADVOGADO' : 'CLIENTE'),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: secondaryTextColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                fontSize: 14.5,
                color: textColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9.5,
                    color: secondaryTextColor,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 13, color: secondaryTextColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
