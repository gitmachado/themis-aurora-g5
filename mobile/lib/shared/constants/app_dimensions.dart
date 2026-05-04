import 'package:flutter/material.dart';

class AppDimensions {
  AppDimensions._();

  // Spacing / Margins
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Screen Padding
  static const double screenPadding = 20.0;
  static const double contentPadding = 16.0;

  // Border Radius
  static const double radiusS = 10.0;
  static const double radiusM = 14.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 26.0;
  static const double radiusXXL = 34.0;
  static const double radiusCircular = 100.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;

  // Specific Heights/Widths
  static const double appBarHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;

  static double bottomPadding(BuildContext context) {
    return 88.0 + MediaQuery.of(context).padding.bottom;
  }
}
