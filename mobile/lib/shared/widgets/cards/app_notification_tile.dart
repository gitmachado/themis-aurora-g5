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
  final Function(String id) onToggleRead;
  final Function(String id) onDelete;
  final VoidCallback? onTap;

  const AppNotificationTile({
    super.key,
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.isRead,
    required this.onToggleRead,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notif_$id'),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete(id);
        } else {
          onToggleRead(id);
        }
      },
      background: _buildSwipeBackground(
        color: isRead ? AppColors.textCaption : AppColors.primary,
        icon: isRead
            ? Icons.mark_email_unread_rounded
            : Icons.mark_email_read_rounded,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppColors.error,
        icon: Icons.delete_outline_rounded,
        alignment: Alignment.centerRight,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surface : AppColors.yellowSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead ? AppColors.line : Colors.transparent,
          ),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: _getOverlayColor(type),
            child: Icon(_getIcon(type), color: _getIconColor(type), size: 20),
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
          onTap: onTap ?? () => onToggleRead(id),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
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
