import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class CameraBottomOverlay extends StatelessWidget {
  final Function(BuildContext) onCapture;

  const CameraBottomOverlay({
    super.key,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.04,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.black.withOpacity(0.6),
              AppColors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            // Circular photo button
            Builder(
              builder: (builderContext) => GestureDetector(
                onTap: () {
                  onCapture(builderContext);
                },
                child: Container(
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(
                      color: AppColors.white,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            // Photo mode text
            TextComponent(
              labelText: TextConstants.photoMode,
              color: AppColors.white,
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ],
        ),
      ),
    );
  }
}
