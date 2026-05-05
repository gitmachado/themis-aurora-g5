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
        backgroundColor = AppColors.surface2;
        textColor = AppColors.ink2;
        break;
      case BadgeType.success:
        backgroundColor = AppColors.successBackground;
        textColor = AppColors.success;
        break;
      case BadgeType.error:
        backgroundColor = AppColors.errorBackground;
        textColor = AppColors.error;
        break;
      case BadgeType.warning:
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.warning;
        break;
      case BadgeType.neutral:
        backgroundColor = AppColors.surface2;
        textColor = AppColors.ink3;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
