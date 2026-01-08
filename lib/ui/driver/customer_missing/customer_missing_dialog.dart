import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class CustomerMissingDialog extends StatelessWidget {
  final VoidCallback onProceed;
  final VoidCallback? onCancel;

  const CustomerMissingDialog({
    super.key,
    required this.onProceed,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onProceed,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomerMissingDialog(
        onProceed: onProceed,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.06),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Car Icon with Circular Arrow
            Container(
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Car Icon
                  Icon(
                    Icons.directions_car,
                    size: screenWidth * 0.12,
                    color: AppColors.white,
                  ),
                  // Refresh/Repark Icon - positioned at top right
                  Positioned(
                    right: screenWidth * 0.02,
                    top: screenWidth * 0.02,
                    child: Icon(
                      Icons.refresh,
                      size: screenWidth * 0.05,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Main Question
            TextComponent(
              labelText: 'Are you sure to re-park the car?',
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.015),

            // Explanatory Text
            TextComponent(
              labelText:
                  'This will cancel the retrieval and you must park the car again.',
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.03),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.055,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onProceed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextComponent(
                      labelText: 'Proceed to Re-Park',
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.black,
                      size: screenWidth * 0.05,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: TextComponent(
                labelText: 'Cancel',
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
