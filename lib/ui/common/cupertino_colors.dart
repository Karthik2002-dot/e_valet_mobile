
import 'dart:ui';
import 'package:flutter/cupertino.dart';
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
