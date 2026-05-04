import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Plus Jakarta Sans';
  static const String monoFontFamily = 'JetBrains Mono';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 29,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textBody,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textCaption,
    height: 1.35,
  );

  static const TextStyle tiny = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textCaption,
    height: 1.25,
  );

  static const TextStyle cap = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textCaption,
    letterSpacing: 0.8,
    height: 1.2,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textCaption,
    height: 1.2,
  );
}
