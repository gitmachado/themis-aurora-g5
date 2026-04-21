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
        icon: isRead ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppColors.error,
        icon: Icons.delete_outline_rounded,
        alignment: Alignment.centerRight,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isRead ? Colors.transparent : AppColors.primaryOverlay,
          border: const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: ListTile(
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
                  color: isRead ? AppColors.textCaption : AppColors.textPrimary.withValues(alpha: 0.8),
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
        return AppColors.primary;
      case 'file':
        return AppColors.warning;
      case 'procedure':
        return const Color(0xFF673AB7);
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
        return AppColors.primaryOverlay;
      case 'file':
        return AppColors.warningOverlay;
      case 'procedure':
        return const Color(0xff673ab7).withValues(alpha: 0.1);
      case 'chat':
        return AppColors.successOverlay;
      case 'alert':
        return AppColors.errorOverlay;
      default:
        return AppColors.textCaption.withValues(alpha: 0.1);
    }
  }
}

