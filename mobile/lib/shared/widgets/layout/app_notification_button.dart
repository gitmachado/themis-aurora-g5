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
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surface2,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              size: size,
              color: AppColors.ink2,
            ),
            onPressed: onTap,
            padding: EdgeInsets.zero,
          ),
        ),
        if (notificationCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.yellow,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                notificationCount > 9 ? '+9' : notificationCount.toString(),
                style: const TextStyle(
                  color: AppColors.ink,
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
