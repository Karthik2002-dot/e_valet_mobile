import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class SlideToConfirmButton extends StatelessWidget {
  final String sessionId;
  final bool isLoading;
  final VoidCallback onConfirm;

  /// When false, button is disabled (e.g. for 30s after Collect Keys). No UI change.
  final bool enabled;

  /// When true, button expands to fill parent and uses large label (like review OK).
  final bool useBigStyle;

  const SlideToConfirmButton({
    super.key,
    required this.sessionId,
    required this.isLoading,
    required this.onConfirm,
    this.enabled = true,
    this.useBigStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final button = ElevatedButton(
      onPressed: (isLoading || !enabled) ? null : onConfirm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.7),
        disabledForegroundColor: AppColors.black.withOpacity(0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.my_location,
                  size: useBigStyle ? screenWidth * 0.08 : screenHeight * 0.04,
                  color: AppColors.black,
                ),
                SizedBox(width: useBigStyle ? 16 : 10),
                TextComponent(
                  labelText: TextConstants.slideToConfirmArrival,
                  fontSize:
                      useBigStyle ? screenWidth * 0.06 : screenHeight * 0.025,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ],
            ),
    );

    if (useBigStyle) {
      return SizedBox(
          width: double.infinity, height: double.infinity, child: button);
    }
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.07,
      child: button,
    );
  }
}
