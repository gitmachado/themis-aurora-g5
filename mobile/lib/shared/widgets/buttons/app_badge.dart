import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

enum BadgeType { primary, success, error, warning, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const AppBadge({
    super.key,
    required this.label,
    this.type = BadgeType.primary,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case BadgeType.primary:
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        break;
      case BadgeType.success:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case BadgeType.error:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        break;
      case BadgeType.warning:
        backgroundColor = AppColors.secondaryDark.withValues(alpha: 0.1);
        textColor = AppColors.secondaryDark;
        break;
      case BadgeType.neutral:
        backgroundColor = AppColors.divider.withValues(alpha: 0.3);
        textColor = AppColors.textCaption;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
