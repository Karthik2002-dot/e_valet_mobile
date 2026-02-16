import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class SlideToConfirmButton extends StatelessWidget {
  final String sessionId;
  final bool isLoading;
  final VoidCallback onConfirm;

  /// When false, button is disabled (e.g. for 30s after Collect Keys).
  final bool enabled;

  /// When > 0, button is disabled and this countdown is shown inside a round circle.
  final int disabledRemainingSeconds;

  /// When true, button expands to fill parent and uses large label (like review OK).
  final bool useBigStyle;

  const SlideToConfirmButton({
    super.key,
    required this.sessionId,
    required this.isLoading,
    required this.onConfirm,
    this.enabled = true,
    this.disabledRemainingSeconds = 0,
    this.useBigStyle = false,
  });

  Widget _leadingWidget(double screenHeight, double screenWidth) {
    final showCountdown = !enabled && disabledRemainingSeconds > 0;
    if (showCountdown) {
      final size = useBigStyle ? 44.0 : 36.0;
      final fontSize = useBigStyle ? 20.0 : 16.0;
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.greyLight,
          shape: BoxShape.circle,
        ),
        child: TextComponent(
          labelText: '$disabledRemainingSeconds',
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.black.withOpacity(0.85),
        ),
      );
    }
    return Icon(
      Icons.my_location,
      size: useBigStyle ? screenWidth * 0.08 : screenHeight * 0.04,
      color: AppColors.black,
    );
  }

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
                _leadingWidget(screenHeight, screenWidth),
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
