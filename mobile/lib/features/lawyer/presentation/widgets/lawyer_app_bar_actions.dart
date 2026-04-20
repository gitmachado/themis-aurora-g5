import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';

class LawyerAppBarActions extends StatelessWidget {
  final int notificationCount;
  final int chatCount;

  const LawyerAppBarActions({
    super.key,
    this.notificationCount = 2,
    this.chatCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionIcon(
          context,
          icon: Icons.chat_bubble_outline_rounded,
          count: chatCount,
          onTap: () => Navigator.pushNamed(context, '/lawyer-chats'),
        ),
        _buildActionIcon(
          context,
          icon: Icons.notifications_none_outlined,
          count: notificationCount,
          onTap: () => Navigator.pushNamed(context, '/lawyer-notifications'),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildActionIcon(BuildContext context, {required IconData icon, required int count, required VoidCallback onTap}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(icon, color: AppColors.primary, size: 22),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: Text(
                count > 9 ? '+9' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
