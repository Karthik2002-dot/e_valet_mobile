import 'package:flutter/material.dart';

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
  static const Color lightBeigeBackground =
      Color(0xFFF5F5F0); // Light beige background
  static const Color surface = Colors.white;
  static const Color surfaceBorder = Color(0xFFEAEAEA);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow10 = Color(0x1A000000); // 10% black
  static const Color mutedText = Color(0xFF6B7280);

  // Grey shades
  static const Color greyLight = Color(0xFFE0E0E0); // Colors.grey.shade300

  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color white = Colors.white;
  static const Color blue = Colors.blue;
  static const Color purple = Colors.purple;
  static const Color transparent = Colors.transparent;

  // QR Scanner specific colors
  static const Color qrSuccessBackground =
      Color(0x1A4CAF50); // green.withOpacity(0.1)
  static const Color qrSuccessBorder = Color(0xFF4CAF50); // Colors.green
  static const Color qrSuccessText = Color(0xFF4CAF50); // Colors.green
  static const Color qrErrorBackground =
      Color(0x1AF44336); // red.withOpacity(0.1)
  static const Color qrProcessingOverlay =
      Color(0x80000000); // black.withOpacity(0.5)
  static const Color qrSuccessBorderLight =
      Color(0x4D4CAF50); // green.withOpacity(0.3)

  // Additional QR Scanner colors
  static const Color qrSuccessColor = Color(0xFF10B981); // Bright green
  static const Color qrErrorColor = Color(0xFFEF4444); // Bright red
  static const Color qrSuccessBg = Color(0xFFECFDF5); // Light green background
  static const Color qrErrorBg = Color(0xFFFEF2F2); // Light red background

  // Manual Request
  static const Color manualRequestFillColor = Color(0xFFE0E0E0);
  static const Color orange = Color(0xFFFFA500);
}
