import 'package:flutter/material.dart';

/// Design-system typography: Times New Roman → Plus Jakarta Sans → Inter.
class AppTypography {
  AppTypography._();

  static const String primaryFamily = 'Times New Roman';
  static const List<String> fallbackFamilies = ['Plus Jakarta Sans', 'Inter'];

  // Type scale (px)
  static const double hero = 48;
  static const double section = 32;
  static const double subheading = 20;
  static const double body = 15;
  static const double label = 12;
  static const double cta = 15;

  static TextStyle style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: primaryFamily,
      fontFamilyFallback: fallbackFamilies,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  static TextStyle get heroStyle =>
      style(fontSize: hero, fontWeight: FontWeight.bold);
  static TextStyle get sectionStyle =>
      style(fontSize: section, fontWeight: FontWeight.bold);
  static TextStyle get subheadingStyle =>
      style(fontSize: subheading, fontWeight: FontWeight.w600);
  static TextStyle get bodyStyle => style(fontSize: body);
  static TextStyle get labelStyle =>
      style(fontSize: label, fontWeight: FontWeight.w500);
  static TextStyle get ctaStyle =>
      style(fontSize: cta, fontWeight: FontWeight.w600);

  /// Merges [base] with the app font stack; widget-level overrides win.
  static TextStyle merge(TextStyle? base) {
    final resolved = style();
    if (base == null) return resolved;
    return resolved.merge(base);
  }
}
