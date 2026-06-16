import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';

class AppLogo extends StatelessWidget {
  static const assetPath = 'assets/images/niloufer.logo.png';

  /// Wide banner logo; width is derived from height when not provided.
  static const aspectRatio = 4.2;

  final double height;
  final double? width;

  /// Coral accent bar under the logo (e.g. drawer branding).
  final bool showAccentUnderline;

  const AppLogo({
    super.key,
    required this.height,
    this.width,
    this.showAccentUnderline = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidth = width ?? height * aspectRatio;

    final logo = SizedBox(
      width: logoWidth,
      height: height,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
      ),
    );

    if (!showAccentUnderline) return logo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        logo,
        const SizedBox(height: 6),
        Container(
          height: 3,
          width: logoWidth,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
