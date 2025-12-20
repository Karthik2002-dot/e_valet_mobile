import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_status_card_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_welcome_break_row_widget.dart';

class DriverHeaderWidget extends StatelessWidget {
  final String driverName;
  final bool isOnline;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const DriverHeaderWidget({
    super.key,
    required this.driverName,
    required this.isOnline,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive content height (excluding AppBar)
    final contentHeight = isDesktop
        ? screenHeight * 0.15
        : isTablet
            ? screenHeight * 0.17
            : (screenHeight * 0.18).clamp(140.0, 180.0);

    final padding = screenWidth * 0.04;

    return Container(
      width: screenWidth,
      height: contentHeight,
      decoration: const BoxDecoration(
        color: AppColors.primary, // Orange/gold background
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome/Driver name on left, On Break toggle on right
            DriverWelcomeBreakRowWidget(
              driverName: driverName,
              screenWidth: screenWidth,
              isTablet: isTablet,
              isDesktop: isDesktop,
            ),
            const Spacer(),
            // Status Card (267px width, 43px height) - centered at bottom
            DriverStatusCardWidget(
              isOnline: isOnline,
              screenWidth: screenWidth,
              isTablet: isTablet,
              isDesktop: isDesktop,
            ),
          ],
        ),
      ),
    );
  }
}
