import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ThemisAI design tokens
  static const Color ink = Color(0xFF1A1A1A);
  static const Color ink2 = Color(0xFF3A3A3A);
  static const Color ink3 = Color(0xFF6E6E6E);
  static const Color ink4 = Color(0xFFA3A3A3);

  static const Color yellow = Color(0xFFF5C518);
  static const Color yellow2 = Color(0xFFFFD93D);
  static const Color yellowSoft = Color(0xFFFFF6CE);
  static const Color yellowDeep = Color(0xFFB98E00);

  static const Color background = Color(0xFFFBFAF6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF4F2EC);
  static const Color surface3 = Color(0xFFECEAE2);

  static const Color line = Color(0xFFECEAE2);
  static const Color line2 = Color(0xFFF4F2EC);

  // Alert & Feedback
  static const Color error = Color(0xFFB0413E);
  static const Color errorBackground = Color(0xFFF9ECEB);
  static const Color errorOverlay = errorBackground;

  static const Color success = Color(0xFF3F7D58);
  static const Color successBackground = Color(0xFFECF3EE);
  static const Color successOverlay = successBackground;

  static const Color warning = Color(0xFFB07A00);
  static const Color warningLight = Color(0xFFFBF1D6);
  static const Color warningOverlay = warningLight;

  static const Color info = Color(0xFF5B6B7B);
  static const Color infoBackground = Color(0xFFEEF2F5);

  // Legacy aliases used by the existing app.
  static const Color primary = ink;
  static const Color primaryLight = surface2;
  static const Color primaryDark = ink;
  static const Color primaryOverlay = Color(0x1A1A1A1A);

  static const Color secondary = yellow;
  static const Color secondaryLight = yellow;
  static const Color secondaryDark = yellowDeep;
  static const Color secondaryOverlay = yellowSoft;

  static const Color textPrimary = ink;
  static const Color textBody = ink2;
  static const Color textCaption = ink3;
  static const Color white = Colors.white;
  static const Color border = line;
  static const Color chatBubbleMe = yellow;
  static const Color divider = line;
}
