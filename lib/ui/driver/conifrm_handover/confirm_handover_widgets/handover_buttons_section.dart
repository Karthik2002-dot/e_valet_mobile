import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class HandoverButtonsSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onConfirmHandover;
  final VoidCallback? onCustomerMissing;

  const HandoverButtonsSection({
    super.key,
    required this.isLoading,
    required this.onConfirmHandover,
    this.onCustomerMissing,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Confirm Handover Button
        SizedBox(
          width: double.infinity,
          height: screenHeight * 0.07,
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirmHandover,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: AppColors.black)
                : TextComponent(
                    labelText: TextConstants.confirmHandover,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
          ),
        ),

        SizedBox(height: screenHeight * 0.02),

        // Customer Missing Button
        SizedBox(
          width: double.infinity,
          height: screenHeight * 0.07,
          child: ElevatedButton(
            onPressed: onCustomerMissing,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              elevation: 0,
              side: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning,
                  color: AppColors.error,
                  size: screenWidth * 0.06,
                ),
                SizedBox(width: screenWidth * 0.03),
                TextComponent(
                  labelText: TextConstants.customerMissing,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
                SizedBox(width: screenWidth * 0.02),
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.error,
                  size: screenWidth * 0.05,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
