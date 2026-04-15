import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class DriverBreakToggleWidget extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final bool isDesktop;

  const DriverBreakToggleWidget({
    super.key,
    required this.screenWidth,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      builder: (context, statusState) {
        // Get break status from API, fallback to false if not loaded yet
        final isOnBreak = statusState is DriverStatusLoaded
            ? statusState.status.isOnBreak
            : statusState is DriverBreakToggleLoading
                ? statusState.previousStatus?.isOnBreak ?? false
            : false;

        // Check if we're in a loading state (updating break status)
        final isLoading =
            statusState is DriverStatusLoading ||
            statusState is DriverBreakToggleLoading;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextComponent(
              labelText:
                  t.getByKey('onBreakScreen', TextConstants.headerOnBreak),
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
                        ? 0.6
                        : isTablet
                            ? 0.7
                            : 0.75,
                    child: Switch(
                      value: isOnBreak,
                      onChanged: (value) {
                        context.read<DriverStatusBloc>().add(
                              DriverBreakToggled(value),
                            );
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
