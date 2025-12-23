import 'dart:io';
import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class PreviewImageCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRetake;

  const PreviewImageCard({
    super.key,
    required this.imagePath,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow10,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Captured image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            child: Image.file(
              File(imagePath),
              width: double.infinity,
              height: screenHeight * 0.3,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: screenHeight * 0.3,
                  color: AppColors.greyLight,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: AppColors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Retake button (centered and narrower with circular corners)
          Center(
            child: SizedBox(
              width: screenWidth * 0.7, // 70% width
              height: screenHeight * 0.055, // Slightly shorter height
              child: ElevatedButton.icon(
                onPressed: onRetake,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.08), // More circular corners
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  Icons.camera_alt,
                  color: AppColors.white,
                  size: screenWidth * 0.05,
                ),
                label: TextComponent(
                  labelText: TextConstants.retakeButton,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
