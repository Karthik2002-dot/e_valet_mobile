import 'package:flutter/material.dart';

/// App Color Scheme — design-system tokens.
class AppColors {
  AppColors._();

  // Brand
  /// Coral 400 — headers, primary CTAs (#D85A30 only; no other orange hex).
  static const Color coral = Color(0xFFD85A30);
  static const Color orange = coral;
  static const Color primary = coral;
  static const Color primaryDark = coral;
  static const Color accent = coral;
  static const Color headerYellow = coral;
  static const Color actionButtonYellow = coral;
  static const Color primarySoft = Color(0x1AD85A30);
  static const Color coralLight = Color(0x33D85A30);

  // Neutrals
  static const Color nearBlack = Color(0xFF1C1C1E);
  static const Color offWhite = Color(0xFFF5F5F0);
  static const Color trackGray = Color(0xFFE8E8E4);
  static const Color footerGray = Color(0xFF888888);
  static const Color disabledBackground = trackGray;
  static const Color disabledText = footerGray;

  // Semantic
  static const Color infoBlue = Color(0xFF378ADD);
  static const Color secondary = Color(0xFF39756A);

  // Surfaces
  static const Color background = Color(0xFFF7F7F9);
  static const Color lightBeigeBackground = Color(0xFFF5F5EC);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color surfaceBorder = trackGray;
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow10 = Color(0x1A000000);
  static const Color mutedText = Color(0xFF6B7280);

  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color cancelAssignmentIcon = Color(0xFFFF5722);
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color white = Colors.white;
  static const Color blue = Colors.blue;
  static const Color purple = Colors.purple;
  static const Color transparent = Colors.transparent;

  // QR Scanner
  static const Color qrSuccessBackground = Color(0x1A4CAF50);
  static const Color qrSuccessBorder = Color(0xFF4CAF50);
  static const Color qrSuccessText = Color(0xFF4CAF50);
  static const Color qrErrorBackground = Color(0x1AF44336);
  static const Color qrProcessingOverlay = Color(0x80000000);
  static const Color qrSuccessBorderLight = Color(0x4D4CAF50);
  static const Color qrSuccessColor = Color(0xFF10B981);
  static const Color qrErrorColor = Color(0xFFEF4444);
  static const Color qrSuccessBg = Color(0xFFECFDF5);
  static const Color qrErrorBg = Color(0xFFFEF2F2);

  static const Color manualRequestFillColor = Color(0xFFE0E0E0);
}
