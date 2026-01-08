import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_break_toggle_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_online_toggle_widget.dart';

class DriverHeaderWidget extends StatelessWidget {
  final bool isOnline;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const DriverHeaderWidget({
    super.key,
    required this.isOnline,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive content height (excluding AppBar) - slightly increased for better spacing
    final contentHeight = isDesktop
        ? screenHeight * 0.06
        : isTablet
            ? screenHeight * 0.07
            : screenHeight * 0.06;

    final padding = screenWidth * 0.02;

    return Container(
      width: screenWidth,
      height: contentHeight,
      decoration: const BoxDecoration(
        color: AppColors.primary, // Orange/gold background
      ),
      child: BlocBuilder<DriverStatusBloc, DriverStatusState>(
        builder: (context, statusState) {
          // Get online status from API, fallback to prop if not loaded yet
          final isCurrentlyOnline = statusState is DriverStatusLoaded
              ? statusState.status.isOnline
              : isOnline;

          return Stack(
            children: [
              // On Break toggle positioned at very top-left, just below logo
              if (isCurrentlyOnline)
                Positioned(
                  top: 4, // Minimal offset from top (4 pixels)
                  left: padding * 1.5, // Extra gap from left edge
                  child: DriverBreakToggleWidget(
                    screenWidth: screenWidth,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                  ),
                ),

              // Online toggle positioned at very top-right corner
              Positioned(
                top: 4, // Minimal offset from top (4 pixels)
                right: padding,
                child: DriverOnlineToggleWidget(
                  isOnline: isOnline,
                  screenWidth: screenWidth,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
