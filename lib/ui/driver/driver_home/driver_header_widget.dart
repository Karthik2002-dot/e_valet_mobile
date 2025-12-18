import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_event.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_status_card_widget.dart';

class DriverHeaderWidget extends StatelessWidget {
  final String driverName;
  final bool isOnBreak;
  final bool isOnline;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const DriverHeaderWidget({
    super.key,
    required this.driverName,
    required this.isOnBreak,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side: Welcome and driver name (stacked vertically)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextComponent(
                      labelText: TextConstants.headerWelcome,
                      fontSize: isDesktop
                          ? screenWidth * 0.012
                          : isTablet
                              ? screenWidth * 0.02
                              : screenWidth * 0.035,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withOpacity(0.8),
                    ),
                    TextComponent(
                      labelText: driverName,
                      fontSize: isDesktop
                          ? screenWidth * 0.018
                          : isTablet
                              ? screenWidth * 0.028
                              : screenWidth * 0.05,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ],
                ),
                // Right side: On Break toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextComponent(
                      labelText: TextConstants.headerOnBreak,
                      fontSize: isDesktop
                          ? screenWidth * 0.012
                          : isTablet
                              ? screenWidth * 0.02
                              : screenWidth * 0.035,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Transform.scale(
                      scale: isDesktop
                          ? 0.8
                          : isTablet
                              ? 0.9
                              : 1.0,
                      child: Switch(
                        value: isOnBreak,
                        onChanged: (value) {
                          context
                              .read<DriverMenuBloc>()
                              .add(DriverOnBreakToggled(value));
                        },
                        activeColor: AppColors.white,
                        inactiveThumbColor: AppColors.grey,
                        inactiveTrackColor: AppColors.greyLight,
                      ),
                    ),
                  ],
                ),
              ],
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
