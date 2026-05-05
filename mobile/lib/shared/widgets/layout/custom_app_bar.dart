import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'app_notification_button.dart';

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
  final bool showDivider;
  final Color? backgroundColor;

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
    this.showDivider = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasTrailingActions =
        (actions?.isNotEmpty ?? false) || showNotificationButton;

    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: showBackButton ? 68 : null,
      titleSpacing: showBackButton ? 0 : 20,
      title:
          titleWidget ??
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Text(
              title,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      actions: hasTrailingActions
          ? [
              ...?actions,
              if (showNotificationButton)
                AppNotificationButton(
                  notificationCount: notificationCount,
                  onTap:
                      onNotificationTap ??
                      () => Navigator.pushNamed(context, '/notifications'),
                ),
              const SizedBox(width: 8),
            ]
          : null,
      leading:
          leading ??
          (showBackButton
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                )
              : null),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.ink, size: 24),
      bottom:
          bottom ??
          (showDivider
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(color: AppColors.line2, height: 1),
                )
              : null),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight +
        (bottom?.preferredSize.height ?? (showDivider ? 1.0 : 0.0)),
  );
}
