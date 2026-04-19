import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';

final class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.h1,
          titleLarge: AppTextStyles.h2,
          bodyLarge: AppTextStyles.body,
          bodySmall: AppTextStyles.caption,
        ),
      );
}
