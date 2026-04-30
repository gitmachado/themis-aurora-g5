import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;
  final IconData? icon;
  final Color? iconColor;
  final bool isDescription;

  const LabeledField({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.icon,
    this.iconColor,
    this.isDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: isDescription
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor ?? AppColors.primary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child:
                  valueWidget ??
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: isDescription ? 13 : 14,
                      height: isDescription ? 1.5 : 1.2,
                      color: isDescription
                          ? const Color(0xFF475569)
                          : AppColors.textPrimary,
                      fontWeight: isDescription
                          ? FontWeight.normal
                          : FontWeight.normal,
                    ),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
