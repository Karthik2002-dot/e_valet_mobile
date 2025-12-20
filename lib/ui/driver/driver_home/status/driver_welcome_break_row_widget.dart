import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class DriverWelcomeBreakRowWidget extends StatelessWidget {
  final String driverName;
  final double screenWidth;
  final bool isTablet;
  final bool isDesktop;

  const DriverWelcomeBreakRowWidget({
    super.key,
    required this.driverName,
    required this.screenWidth,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      builder: (context, statusState) {
        // Get break status from API, fallback to false if not loaded yet
        final isOnBreak = statusState is DriverStatusLoaded
            ? statusState.status.isOnBreak
            : false;

        // Check if we're in a loading state (updating break status)
        final isLoading = statusState is DriverStatusLoading;

        return Row(
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
            // Show loader when updating break status, otherwise show switch
            isLoading
                ? SizedBox(
                    width: isDesktop
                        ? screenWidth * 0.025
                        : isTablet
                            ? screenWidth * 0.035
                            : screenWidth * 0.045,
                    height: isDesktop
                        ? screenWidth * 0.025
                        : isTablet
                            ? screenWidth * 0.035
                            : screenWidth * 0.045,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : Transform.scale(
                    scale: isDesktop
                        ? 0.8
                        : isTablet
                            ? 0.9
                            : 1.0,
                    child: Switch(
                      value: isOnBreak,
                      onChanged: (value) {
                        // Only call API, don't update local state immediately
                        // The toggle will update automatically when API succeeds
                        context
                            .read<DriverStatusBloc>()
                            .add(DriverBreakToggled(value));
                      },
                      activeColor: AppColors.white,
                      inactiveThumbColor: AppColors.grey,
                      inactiveTrackColor: AppColors.greyLight,
                    ),
                  ),
          ],
        ),
      ],
        );
      },
    );
  }
}
