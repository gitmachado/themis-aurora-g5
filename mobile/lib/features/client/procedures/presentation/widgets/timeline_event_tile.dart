import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';

class TimelineEventTile extends StatelessWidget {
  final String date;
  final String description;
  final String? title;
  final String? responsible;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final bool isLast;
  final bool isFirst;

  const TimelineEventTile({
    super.key,
    required this.date,
    required this.description,
    this.title,
    this.responsible,
    this.icon,
    this.iconBackgroundColor,
    this.isLast = false,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna Esquerda: Ponto e Linha
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        iconBackgroundColor ??
                        (isFirst ? AppColors.yellow : AppColors.background),
                    shape: BoxShape.circle,
                    border: iconBackgroundColor == null
                        ? Border.all(
                            color: isFirst ? AppColors.ink : AppColors.divider,
                            width: isFirst ? 2.5 : 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    icon ?? (isFirst ? Icons.check : Icons.circle),
                    size: 16,
                    color: isFirst ? AppColors.ink : AppColors.divider,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.divider.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Coluna Direita: Conteúdo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isFirst
                            ? AppColors.textPrimary
                            : AppColors.textCaption,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      color: AppColors.textCaption,
                    ),
                  ),
                  if (responsible != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Responsável: $responsible',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.ink3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        description,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: isFirst
                              ? AppColors.textBody
                              : AppColors.textCaption,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
