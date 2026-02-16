import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class PreviewSubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool isReparking;
  final bool isLoading;

  /// When false, button is disabled (e.g. until parking location is entered).
  final bool isEnabled;

  /// When set, shown instead of Submit / Submit Re-Park (e.g. 'Done').
  final String? overrideLabel;

  const PreviewSubmitButton({
    super.key,
    required this.onSubmit,
    this.isReparking = false,
    this.isLoading = false,
    this.isEnabled = true,
    this.overrideLabel,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final buttonHeight = screenHeight * 0.085;
    final textSize = screenWidth * 0.072;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: (isLoading || !isEnabled) ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextComponent(
                    labelText: overrideLabel ??
                        (isReparking
                            ? TextConstants.submitRePark
                            : TextConstants.submitButton),
                    fontSize: textSize,
                    color: AppColors.white,
                  ),
                  if (overrideLabel == null) ...[
                    SizedBox(width: screenWidth * 0.02),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.white,
                      size: textSize,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
