import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class ThemisLogo extends StatelessWidget {
  final double size;
  final bool dark;

  const ThemisLogo({super.key, this.size = 40, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final markColor = dark ? AppColors.yellow : AppColors.ink;
    final glyphColor = dark ? AppColors.ink : AppColors.yellow;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: markColor,
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Text(
            'θ',
            style: TextStyle(
              color: glyphColor,
              fontFamily: AppTextStyles.fontFamily,
              fontSize: size * 0.58,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        SizedBox(width: size * 0.25),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: dark ? AppColors.white : AppColors.ink,
              fontFamily: AppTextStyles.fontFamily,
              fontSize: size * 0.5,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
            children: [
              const TextSpan(text: 'Themis'),
              TextSpan(
                text: 'AI',
                style: TextStyle(
                  color: dark ? AppColors.yellow : AppColors.yellowDeep,
                ),
              ),
            ],
          ),
        ),
      ],
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

  const ThemisSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: selectedIndex == index
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectedIndex == index
                          ? AppColors.ink
                          : AppColors.ink3,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ThemisActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback? onTap;

  const ThemisActionRow({
    super.key,
    required this.icon,
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
              child: Icon(icon, color: iconColor, size: 20),
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
