import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class AppNotificationTile extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type;
  final bool isRead;
  final bool isSelected;
  final bool isSelectionMode;
  final Function(String id) onToggleRead;
  final Function(String id) onDelete;
  final Function(String id, bool selected)? onSelected;
  final Function(String id)? onLongPress;
  final VoidCallback? onTap;

  const AppNotificationTile({
    super.key,
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.isRead,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onToggleRead,
    required this.onDelete,
    this.onSelected,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.yellowSoft.withValues(alpha: 0.5)
            : (isRead ? AppColors.surface : AppColors.yellowSoft),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.yellow
              : (isRead ? AppColors.line : Colors.transparent),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(16),
        leading: isSelectionMode
            ? Checkbox(
                value: isSelected,
                activeColor: AppColors.yellow,
                checkColor: AppColors.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (val) => onSelected?.call(id, val ?? false),
              )
            : CircleAvatar(
                backgroundColor: _getOverlayColor(type),
                child: Icon(
                  _getIcon(type),
                  color: _getIconColor(type),
                  size: 20,
                ),
              ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              body,
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                color: isRead
                    ? AppColors.textCaption
                    : AppColors.textPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: AppColors.textCaption,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: isSelectionMode
            ? () => onSelected?.call(id, !isSelected)
            : (onTap ?? () => onToggleRead(id)),
        onLongPress: isSelectionMode ? null : () => onLongPress?.call(id),
      ),
    );

    return cardContent;
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'lead':
        return Icons.person_add_rounded;
      case 'file':
        return Icons.file_present_rounded;
      case 'procedure':
        return Icons.gavel_rounded;
      case 'chat':
        return Icons.chat_bubble_rounded;
      case 'alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'lead':
        return AppColors.ink;
      case 'file':
        return AppColors.warning;
      case 'procedure':
        return AppColors.info;
      case 'chat':
        return AppColors.success;
      case 'alert':
        return AppColors.error;
      default:
        return AppColors.textCaption;
    }
  }

  Color _getOverlayColor(String type) {
    switch (type) {
      case 'lead':
        return AppColors.yellowSoft;
      case 'file':
        return AppColors.warningOverlay;
      case 'procedure':
        return AppColors.infoBackground;
      case 'chat':
        return AppColors.successOverlay;
      case 'alert':
        return AppColors.errorOverlay;
      default:
        return AppColors.textCaption.withValues(alpha: 0.1);
    }
  }
}
