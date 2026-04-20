import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class NicheChart extends StatelessWidget {
  const NicheChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Casos por Nicho',
            style: AppTextStyles.h2.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('Cível', 0.85, AppColors.primary),
              _buildBar('Trab.', 0.65, AppColors.secondaryLight),
              _buildBar('Fam.', 0.45, AppColors.secondaryDark),
              _buildBar('Cons.', 0.35, AppColors.primary.withValues(alpha: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double percentage, Color color) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 120 * percentage,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textCaption,
          ),
        ),
      ],
    );
  }
}
