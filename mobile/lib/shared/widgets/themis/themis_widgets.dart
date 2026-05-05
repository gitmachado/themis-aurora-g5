import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_assets.dart';

class ThemisLogo extends StatelessWidget {
  final double size;
  final bool dark;

  const ThemisLogo({super.key, this.size = 40, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.logo,
      height: size,
      colorFilter: dark 
        ? const ColorFilter.mode(AppColors.white, BlendMode.srcIn)
        : null,
    );
  }
}

class ThemisAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  const ThemisAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 40,
    this.backgroundColor = AppColors.yellow,
    this.foregroundColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedAvatar = avatarUrl?.isNotEmpty == true ? avatarUrl : null;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      backgroundImage: resolvedAvatar == null
          ? null
          : NetworkImage(resolvedAvatar),
      child: resolvedAvatar == null
          ? Text(
              initials(name),
              style: TextStyle(
                color: foregroundColor,
                fontFamily: AppTextStyles.monoFontFamily,
                fontSize: size * 0.33,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }

  static String initials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return '?';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }
}

class ThemisSectionLabel extends StatelessWidget {
  final String label;

  const ThemisSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: AppTextStyles.cap);
  }
}

class ThemisPill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool dot;
  final EdgeInsetsGeometry padding;

  const ThemisPill({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.surface2,
    this.foregroundColor = AppColors.ink2,
    this.dot = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  const ThemisPill.yellow({
    super.key,
    required this.label,
    this.dot = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) : backgroundColor = AppColors.yellow,
       foregroundColor = AppColors.ink;

  const ThemisPill.success({
    super.key,
    required this.label,
    this.dot = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) : backgroundColor = AppColors.successBackground,
       foregroundColor = AppColors.success;

  const ThemisPill.warning({
    super.key,
    required this.label,
    this.dot = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) : backgroundColor = AppColors.warningLight,
       foregroundColor = AppColors.warning;

  const ThemisPill.error({
    super.key,
    required this.label,
    this.dot = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) : backgroundColor = AppColors.errorBackground,
       foregroundColor = AppColors.error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: foregroundColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: AppTextStyles.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class ThemisSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final TabController? controller;

  const ThemisSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.controller,
    Animation<double>? animation, // Mantido para compatibilidade, mas ignorado se houver controller
  });

  @override
  Widget build(BuildContext context) {
    final effectiveController = controller ?? DefaultTabController.of(context);

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: effectiveController,
        onTap: onChanged,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicator: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.ink3,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        tabs: labels.map((label) => Tab(
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        )).toList(),
      ),
    );
  }
}

class ThemisActionRow extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback? onTap;

  const ThemisActionRow({
    super.key,
    this.icon,
    this.iconWidget,
    required this.label,
    this.iconBackground = AppColors.surface2,
    this.iconColor = AppColors.ink,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: iconWidget ?? Icon(icon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.h2.copyWith(fontSize: 16),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.ink4),
          ],
        ),
      ),
    );
  }
}

class ThemisTimelineDot extends StatelessWidget {
  final bool isCurrent;
  final bool isSuccess;
  final bool isDocument;

  const ThemisTimelineDot({
    super.key,
    this.isCurrent = false,
    this.isSuccess = false,
    this.isDocument = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCurrent || isDocument
        ? AppColors.yellow
        : isSuccess
        ? AppColors.success
        : AppColors.surface;
    final borderColor = isCurrent
        ? AppColors.ink
        : isSuccess
        ? AppColors.success
        : isDocument
        ? AppColors.yellow
        : AppColors.ink4;

    return Container(
      width: isCurrent ? 14 : 12,
      height: isCurrent ? 14 : 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.25),
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
    );
  }
}

class ThemisAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDestructive;

  const ThemisAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.cancelLabel = 'Cancelar',
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.errorBackground
                    : AppColors.yellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDestructive
                    ? Icons.delete_forever_rounded
                    : Icons.warning_amber_rounded,
                color: isDestructive ? AppColors.error : AppColors.yellowDeep,
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.ink,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.ink2,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      cancelLabel,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.ink2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive
                          ? AppColors.error
                          : AppColors.yellow,
                      foregroundColor: isDestructive
                          ? AppColors.white
                          : AppColors.ink,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
