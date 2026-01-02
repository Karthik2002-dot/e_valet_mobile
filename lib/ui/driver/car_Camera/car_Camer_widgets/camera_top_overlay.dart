import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class CameraTopOverlay extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback onFlashToggle;

  const CameraTopOverlay({
    super.key,
    required this.isFlashOn,
    required this.onFlashToggle,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flash button row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Flash button
                IconButton(
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: AppColors.white,
                    size: screenWidth * 0.06,
                  ),
                  onPressed: onFlashToggle,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            // Instruction text
            Center(
              child: TextComponent(
                labelText: TextConstants.captureCarInstruction,
                textAlign: TextAlign.center,
                color: AppColors.white,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
