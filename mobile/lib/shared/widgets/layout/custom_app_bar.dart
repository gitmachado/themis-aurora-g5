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

  final PreferredSizeWidget? bottom;

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
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: showBackButton ? 0 : 20,
      title: titleWidget ?? Text(
        title,
        style: AppTextStyles.h2.copyWith(color: AppColors.primary),
      ),
      actions: [
        ...?actions,
        if (showNotificationButton)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 24),
                onPressed: onNotificationTap ?? () => Navigator.pushNamed(context, '/notifications'),
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
          ),
        const SizedBox(width: 8),
      ],
      leading: leading ?? (showBackButton ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
        onPressed: () => Navigator.maybePop(context),
      ) : null),
      centerTitle: centerTitle,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
      bottom: bottom ?? PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.divider.withValues(alpha: 0.5),
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 1.0),
      );
}
