import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/scanner_brackets_painter.dart';

class OperatorScannerWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const OperatorScannerWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final scannerHeight = isDesktop
        ? screenHeight * 0.35
        : isTablet
            ? screenHeight * 0.38
            : screenHeight * 0.35;

    final scannerContentWidth = screenWidth * 0.75;
    final scannerContentHeight = scannerHeight * 0.7;
    final borderWidth = screenWidth * 0.005;
    final borderRadius = screenWidth * 0.03;

    return Container(
      width: double.infinity,
      height: scannerHeight,
      decoration: BoxDecoration(
        color: AppColors.lightBeigeBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: borderWidth,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // L-shaped corner brackets
          CustomPaint(
            size: Size(scannerContentWidth, scannerContentHeight),
            painter: ScannerBracketsPainter(
              strokeWidth: borderWidth * 2,
              cornerLength: screenWidth * 0.1,
            ),
          ),
          // Scanning lines
          Container(
            width: scannerContentWidth,
            height: scannerContentHeight,
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: AppColors.primary.withOpacity(0.5),
                  width: borderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
