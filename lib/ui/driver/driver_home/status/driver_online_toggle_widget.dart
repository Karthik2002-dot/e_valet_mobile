import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class DriverOnlineToggleWidget extends StatelessWidget {
  final bool isOnline;
  final double screenWidth;
  final bool isTablet;
  final bool isDesktop;

  const DriverOnlineToggleWidget({
    super.key,
    required this.isOnline,
    required this.screenWidth,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      builder: (context, statusState) {
        // Get online status from API, fallback to prop if not loaded yet
        final onlineStatus = statusState is DriverStatusLoaded
            ? statusState.status.isOnline
            : isOnline;

        // Check if we're in a loading state (updating status)
        final isLoading = statusState is DriverStatusLoading;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextComponent(
              labelText: onlineStatus
                  ? TextConstants.statusOnline
                  : TextConstants.statusOffline,
              fontSize: isDesktop
                  ? screenWidth * 0.012
                  : isTablet
                      ? screenWidth * 0.02
                      : screenWidth * 0.035,
              fontWeight: FontWeight.w400,
              color: AppColors.white,
            ),
            SizedBox(width: screenWidth * 0.02),
            // Show loader when updating status, otherwise show switch
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
                        ? 0.6
                        : isTablet
                            ? 0.7
                            : 0.75,
                    child: Switch(
                      value: onlineStatus,
                      onChanged: (value) {
                        // Only call API, don't update local state immediately
                        // The toggle will update automatically when API succeeds
                        final newStatus = value ? 'ONLINE' : 'OFFLINE';
                        context
                            .read<DriverStatusBloc>()
                            .add(DriverStatusUpdated(newStatus));
                      },
                      activeColor: AppColors.white,
                      inactiveThumbColor: AppColors.grey,
                      inactiveTrackColor: AppColors.greyLight,
                    ),
                  ),
          ],
        );
      },
    );
  }
}
