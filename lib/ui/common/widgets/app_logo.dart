import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  static const assetPath = 'assets/images/niloufer.logo.png';

  /// Wide banner logo; width is derived from height when not provided.
  static const aspectRatio = 4.2;

  final double height;
  final double? width;

  const AppLogo({
    super.key,
    required this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidth = width ?? height * aspectRatio;

    return SizedBox(
      width: logoWidth,
      height: height,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
