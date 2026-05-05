import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class AppFileCard extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String dateAdded;
  final String category;
  final IconData icon;
  final IconData actionIcon;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final Color iconColor;
  final Color iconBackgroundColor;

  final String? subtitle;

  const AppFileCard({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.dateAdded,
    required this.category,
    this.subtitle,
    this.icon = Icons.description_outlined,
    this.actionIcon = Icons.file_download_outlined,
    this.onTap,
    this.onActionTap,
    this.iconColor = AppColors.primary,
    this.iconBackgroundColor = const Color(0xFFEEF2FF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        fileName,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      '$fileSize • Adicionado em $dateAdded',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (onActionTap != null)
                IconButton(
                  onPressed: onActionTap,
                  icon: Icon(actionIcon, color: const Color(0xFF64748B), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                )
              else
                Icon(actionIcon, color: const Color(0xFF64748B), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
