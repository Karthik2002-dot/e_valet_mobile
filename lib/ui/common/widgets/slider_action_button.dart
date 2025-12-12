import 'package:flutter/material.dart';
import 'package:slider_button/slider_button.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class SliderActionButton extends StatelessWidget {
  final String labelText;
  final VoidCallback onSlideComplete;
  final Color buttonColor;
  final Color backgroundColor;
  final Color? labelColor;
  final IconData icon;
  final double? width;
  final double? height;
  final double? radius;
  final bool isLoading;
  final String? loadingText;
  final bool isRound;

  const SliderActionButton({
    super.key,
    required this.labelText,
    required this.onSlideComplete,
    this.buttonColor = Colors.green,
    this.backgroundColor = Colors.grey,
    this.labelColor,
    this.icon = Icons.check_rounded,
    this.width,
    this.height,
    this.radius,
    this.isLoading = false,
    this.loadingText,
    this.isRound = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = width ?? constraints.maxWidth;

        // If loading, show disabled state
        if (isLoading) {
          final buttonHeight = height ?? 60.0;
          final calculatedRadius = isRound ? buttonHeight / 2 : (radius ?? 12);

          return Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(calculatedRadius),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextComponent(
                    labelText: loadingText ?? labelText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: labelColor ?? AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final buttonHeight = height ?? 60.0;
        // Package requirement: buttonSize (default 60) <= height
        // If height < 60, we need to set buttonSize to be <= height
        // If height >= 60, we can use default buttonSize (60)
        final sliderButtonSize =
            buttonHeight < 60 ? (buttonHeight - 4.0) : null;

        // Calculate radius based on shape preference
        final calculatedRadius = isRound
            ? buttonHeight / 2 // Round: radius = half of height
            : (radius ?? 12); // Square/rounded: use provided radius or default

        return SliderButton(
          action: () async {
            onSlideComplete();
            return true;
          },
          label: TextComponent(
            labelText: labelText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: labelColor ?? AppColors.white,
            textAlign: TextAlign.center,
          ),
          icon: Icon(
            icon,
            color: AppColors.white,
            size: 24,
          ),
          width: buttonWidth,
          height: buttonHeight,
          buttonSize: sliderButtonSize,
          radius: calculatedRadius,
          buttonColor: buttonColor,
          backgroundColor: backgroundColor,
          highlightedColor: AppColors.white,
          baseColor: buttonColor,
        );
      },
    );
  }
}
