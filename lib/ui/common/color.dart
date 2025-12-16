import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// App Color Scheme
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Color
  static const Color primary = Color(0xFFF9B231);
  static const Color primaryDark = Color(0xFFC79100);
  static const Color primarySoft = Color(0xFFFFF1D6); // light chip/border
  static const Color accent =
      Color(0xFFFF7A00); // vivid accent used in tabs/buttons
  static const Color headerYellow = Color(0xFFF7B32B); // QR screen header color

  // Secondary Color
  static const Color secondary = Color(0xFF39756A);

  // Surfaces
  static const Color background = Color(0xFFF7F7F9);
  static const Color surface = Colors.white;
  static const Color surfaceBorder = Color(0xFFEAEAEA);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow10 = Color(0x1A000000); // 10% black
  static const Color mutedText = Color(0xFF6B7280);

  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color white = Colors.white;
}

/// Cupertino dynamic color helpers
class AppCupertinoColors {
  AppCupertinoColors._();

  static Color label(BuildContext context) =>
      CupertinoColors.label.resolveFrom(context);

  static Color separator(BuildContext context) =>
      CupertinoColors.separator.resolveFrom(context);

  static Color placeholderText(BuildContext context) =>
      CupertinoColors.placeholderText.resolveFrom(context);

  static Color systemBackground(BuildContext context) =>
      CupertinoColors.systemBackground.resolveFrom(context);

  static const Color activeBlue = CupertinoColors.activeBlue;
}
