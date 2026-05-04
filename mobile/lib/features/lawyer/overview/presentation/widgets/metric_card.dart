import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? valueColor;
  final bool? hasBorder;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.iconColor = AppColors.primary,
    this.backgroundColor,
    this.titleColor,
    this.valueColor,
    this.hasBorder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        color:
            backgroundColor ??
            (iconColor == AppColors.secondaryLight
                ? AppColors.yellowSoft
                : AppColors.surface),
        hasBorder: hasBorder ?? iconColor != AppColors.secondaryLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textCaption,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? AppColors.textCaption,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
