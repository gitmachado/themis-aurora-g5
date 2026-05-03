import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';

class LeadCard extends StatelessWidget {
  final String name;
  final String caseType;
  final String time;
  final String urgency;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onArchive;
  final bool showArchiveAction;

  const LeadCard({
    super.key,
    required this.name,
    required this.caseType,
    required this.time,
    required this.urgency,
    required this.onTap,
    required this.onAccept,
    required this.onArchive,
    this.showArchiveAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final urgencyType = _getUrgencyType();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Hero(
                  tag: 'avatar_$name',
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surface2,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$caseType • $time',
                        style: AppTextStyles.caption.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                AppBadge(label: urgency.toUpperCase(), type: urgencyType),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (showArchiveAction) ...[
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.archive_outlined,
                      color: AppColors.textCaption,
                      onPressed: onArchive,
                      label: 'Arquivar',
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.check_circle_rounded,
                    color: AppColors.ink,
                    onPressed: onAccept,
                    label: 'Aceitar',
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BadgeType _getUrgencyType() {
    switch (urgency.toUpperCase()) {
      case 'ALTA':
      case 'URGENTE':
        return BadgeType.error;
      case 'MÉDIA':
      case 'MEDIA':
        return BadgeType.warning;
      default:
        return BadgeType.primary;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String label,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isPrimary ? AppColors.yellow : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
