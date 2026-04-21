import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AppNotificationButton extends StatelessWidget {
  final int notificationCount;
  final VoidCallback onTap;
  final double size;

  const AppNotificationButton({
    super.key,
    required this.notificationCount,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, size: size, color: AppColors.primary),
          onPressed: onTap,
        ),
        if (notificationCount > 0)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
