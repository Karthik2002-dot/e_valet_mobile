import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/core/profile/operator_overflow_menu.dart';

class OperatorHeaderWidget extends StatelessWidget {
  final String operatorName;
  final bool isOnBreak;
  final bool isOnline;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const OperatorHeaderWidget({
    super.key,
    required this.operatorName,
    required this.isOnBreak,
    required this.isOnline,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive header height: maintain 196px on mobile, scale for larger screens
    // Adjusted to accommodate status bar (43px height) + padding
    final headerHeight = isDesktop
        ? screenHeight * 0.2
        : isTablet
            ? screenHeight * 0.22
            : (screenHeight * 0.25).clamp(200.0, 240.0);

    final logoSize = isDesktop
        ? screenWidth * 0.08
        : isTablet
            ? screenWidth * 0.12
            : screenWidth * 0.2;

    final padding = screenWidth * 0.04;
    final iconSize = isDesktop
        ? screenWidth * 0.02
        : isTablet
            ? screenWidth * 0.035
            : screenWidth * 0.06;

    return Container(
      width: screenWidth,
      height: headerHeight,
      decoration: const BoxDecoration(
        color: AppColors.primary, // Orange/gold background
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Logo on left, Icons on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Logo
                SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    'assets/images/niloufer.logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                // Right side: Language and menu icons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: Image.asset(
                        'assets/images/language.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    OperatorOverflowMenu(),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            // Second row: Welcome/Operator name on left, On Break toggle on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side: Welcome and operator name (stacked vertically)
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
                      labelText: operatorName,
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
                      scale: isDesktop ? 0.8 : isTablet ? 0.9 : 1.0,
                      child: Switch(
                        value: isOnBreak,
                        onChanged: (value) {
                          context
                              .read<OperatorMenuBloc>()
                              .add(OperatorOnBreakToggled(value));
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
            OperatorStatusCardWidget(
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

class OperatorStatusCardWidget extends StatelessWidget {
  final bool isOnline;
  final double screenWidth;
  final bool isTablet;
  final bool isDesktop;

  const OperatorStatusCardWidget({
    super.key,
    required this.isOnline,
    required this.screenWidth,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: (267 * screenWidth / 360).clamp(267.0, screenWidth * 0.9),
        height: (40.3 * MediaQuery.of(context).size.height / 800).clamp(40.3, 57.0),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 0,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.power_settings_new,
                    color: AppColors.black,
                    size: isDesktop
                        ? screenWidth * 0.015
                        : isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.045,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  TextComponent(
                    labelText: TextConstants.statusLabel,
                    fontSize: isDesktop
                        ? screenWidth * 0.014
                        : isTablet
                            ? screenWidth * 0.022
                            : screenWidth * 0.038,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ],
              ),
              Row(
                children: [
                  TextComponent(
                    labelText: isOnline
                        ? TextConstants.statusOnline
                        : TextConstants.statusOffline,
                    fontSize: isDesktop
                        ? screenWidth * 0.014
                        : isTablet
                            ? screenWidth * 0.022
                            : screenWidth * 0.038,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Transform.scale(
                    scale: isDesktop ? 0.75 : isTablet ? 0.85 : 0.9,
                    child: Switch(
                      value: isOnline,
                      onChanged: (value) {
                        context
                            .read<OperatorMenuBloc>()
                            .add(OperatorOnlineStatusToggled(value));
                      },
                      activeColor: AppColors.success,
                      inactiveThumbColor: AppColors.grey,
                      inactiveTrackColor: AppColors.greyLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

