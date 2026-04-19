import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class ProcessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String processNumber;
  final String statusLabel;
  final BadgeType statusType;
  final String statusMessage;
  final int progressPercentage;
  final VoidCallback onTap;

  const ProcessCard({
    super.key,
    required this.icon,
    required this.title,
    required this.processNumber,
    required this.statusLabel,
    required this.statusType,
    required this.statusMessage,
    required this.progressPercentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color progressColor;
    switch (statusType) {
      case BadgeType.success:
        progressColor = AppColors.success;
        break;
      case BadgeType.warning:
        progressColor = AppColors.warning;
        break;
      case BadgeType.primary:
      default:
        progressColor = AppColors.primary;
        break;
    }

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h2.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      processNumber,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              AppBadge(label: statusLabel, type: statusType),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusMessage,
                style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                '$progressPercentage%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: AppColors.divider.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
