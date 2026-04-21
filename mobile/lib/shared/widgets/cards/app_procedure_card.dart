import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/buttons/app_badge.dart';
import '../../widgets/cards/app_card.dart';

class AppProcedureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? statusLabel;
  final BadgeType statusType;
  final String? lastUpdate;
  final int? progressPercentage;
  final IconData? icon;
  final VoidCallback onTap;

  const AppProcedureCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.statusLabel,
    this.statusType = BadgeType.primary,
    this.lastUpdate,
    this.progressPercentage,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
              ],
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (statusLabel != null)
                AppBadge(label: statusLabel!, type: statusType),
            ],
          ),
          if (lastUpdate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.update_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    lastUpdate!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
          if (progressPercentage != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progresso', style: TextStyle(fontSize: 11, color: AppColors.textCaption)),
                Text(
                  '$progressPercentage%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progressPercentage! / 100,
                backgroundColor: AppColors.divider.withValues(alpha: 0.5),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

