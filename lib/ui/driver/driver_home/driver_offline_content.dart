import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class DriverOfflineContent extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const DriverOfflineContent({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight * 0.05),
        // Offline message
        TextComponent(
          labelText: TextConstants.pleaseTurnOnlineToPark,
          fontSize: isDesktop
              ? screenWidth * 0.018
              : isTablet
                  ? screenWidth * 0.028
                  : screenWidth * 0.05,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.04),
        // Large orange emoticon using SVG
        SvgPicture.asset(
          'assets/svg/face.svg',
          width: isDesktop
              ? screenWidth * 0.15
              : isTablet
                  ? screenWidth * 0.25
                  : screenWidth * 0.4,
          height: isDesktop
              ? screenWidth * 0.15
              : isTablet
                  ? screenWidth * 0.25
                  : screenWidth * 0.4,
        ),
        SizedBox(height: screenHeight * 0.04),
        // Second offline message
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
          ),
          child: TextComponent(
            labelText: TextConstants.cannotParkCarOffline,
            fontSize: isDesktop
                ? screenWidth * 0.012
                : isTablet
                    ? screenWidth * 0.02
                    : screenWidth * 0.035,
            fontWeight: FontWeight.w400,
            color: AppColors.black,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: screenHeight * 0.05),
      ],
    );
  }
}
