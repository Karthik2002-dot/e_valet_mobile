import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class PreviewSubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool isReparking;

  const PreviewSubmitButton({
    super.key,
    required this.onSubmit,
    this.isReparking = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.065,
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextComponent(
              labelText: isReparking
                  ? TextConstants.submitRePark
                  : TextConstants.submitButton,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
            SizedBox(width: screenWidth * 0.02),
            Icon(
              Icons.arrow_forward,
              color: AppColors.white,
              size: screenWidth * 0.045,
            ),
          ],
        ),
      ),
    );
  }
}
