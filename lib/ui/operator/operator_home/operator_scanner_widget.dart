import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';

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

// Custom painter for L-shaped brackets
class ScannerBracketsPainter extends CustomPainter {
  final double strokeWidth;
  final double cornerLength;

  ScannerBracketsPainter({
    required this.strokeWidth,
    required this.cornerLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Top-left corner
    canvas.drawLine(
      Offset(0, cornerLength),
      Offset(0, 0),
      paint,
    );
    canvas.drawLine(
      Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
