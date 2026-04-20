import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? titleWidget;
  final bool centerTitle;
  final bool showBackButton;
  final bool showNotificationButton;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.titleWidget,
    this.centerTitle = false,
    this.showBackButton = false,
    this.showNotificationButton = false,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: titleWidget ?? Text(
        title,
        style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontSize: 18),
      ),
      actions: [
        ...?actions,
        if (showNotificationButton)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 28),
                onPressed: onNotificationTap ?? () => Navigator.pushNamed(context, '/notifications'),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      notificationCount > 9 ? '9+' : notificationCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
      ],
      leading: leading ?? (showBackButton ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ) : null),
      centerTitle: centerTitle,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primary),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.divider.withValues(alpha: 0.5),
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
