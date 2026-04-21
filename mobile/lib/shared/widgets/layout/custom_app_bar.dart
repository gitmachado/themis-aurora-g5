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
  final PreferredSizeWidget? bottom;
  final bool showDivider;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.titleWidget,
    this.centerTitle = false,
    this.showBackButton = false,
    this.bottom,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: showBackButton ? 0 : 20,
      title: titleWidget ??
          Text(
            title,
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: 8),
            ]
          : null,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                  onPressed: () => Navigator.maybePop(context),
                )
              : null),
      centerTitle: centerTitle,
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
      bottom: bottom ??
          (showDivider
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    color: AppColors.divider.withValues(alpha: 0.7),
                    height: 1,
                  ),
                )
              : null),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? (showDivider ? 1.0 : 0.0)));
}
