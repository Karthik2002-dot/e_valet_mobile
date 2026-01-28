import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niloufer_valet_mobile/bloc/driver/initiate_repark/initiate_repark_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/initiate_repark/initiate_repark_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/initiate_repark/initiate_repark_state.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_camera_screen.dart';

class CustomerMissingDialog extends StatelessWidget {
  final String sessionId;
  final VoidCallback? onCancel;

  const CustomerMissingDialog({
    super.key,
    required this.sessionId,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required String sessionId,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) => InitiateReparkBloc(),
        child: CustomerMissingDialog(
          sessionId: sessionId,
          onCancel: onCancel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.06),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Car Icon with Circular Arrow
            Container(
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Car Icon
                  Icon(
                    Icons.directions_car,
                    size: screenWidth * 0.12,
                    color: AppColors.white,
                  ),
                  // Refresh/Repark Icon - positioned at top right
                  Positioned(
                    right: screenWidth * 0.02,
                    top: screenWidth * 0.02,
                    child: Icon(
                      Icons.refresh,
                      size: screenWidth * 0.05,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Main Question
            TextComponent(
              labelText: TextConstants.reparkConfirmationTitle,
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.015),

            // Explanatory Text
            TextComponent(
              labelText: TextConstants.reparkConfirmationMessage,
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.03),

            // Proceed Button
            BlocConsumer<InitiateReparkBloc, InitiateReparkState>(
              listener: (context, state) {
                if (state is InitiateReparkSuccess) {
                  Navigator.of(context).pop();
                  // Navigate to camera screen for reparking
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => CarCameraScreen(
                          sessionId: sessionId,
                          isReparking: true,
                          preventBackNavigation: true,
                        ),
                      ),
                    );
                  });
                  SnackBars.showSuccessSnackBar(context, state.response.message);
                } else if (state is InitiateReparkError) {
                  SnackBars.showErrorSnackBar(context, state.message);
                }
              },
              builder: (context, state) {
                final isLoading = state is InitiateReparkLoading;
                return SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.055,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            try {
                              // Request location permission if needed
                              LocationPermission permission =
                                  await LocationService.checkPermission();
                              if (permission == LocationPermission.denied) {
                                permission =
                                    await LocationService.requestPermission();
                              }

                              if (permission == LocationPermission.denied ||
                                  permission ==
                                      LocationPermission.deniedForever) {
                                SnackBars.showErrorSnackBar(
                                  context,
                                  'Location permission is required to initiate repark.',
                                );
                                return;
                              }

                              // Get current location
                              final position =
                                  await LocationService.getCurrentLocation();

                              // Trigger the API call
                              context.read<InitiateReparkBloc>().add(
                                    InitiateReparkRequested(
                                      sessionId: sessionId,
                                      latitude: position.latitude,
                                      longitude: position.longitude,
                                      accuracy: position.accuracy,
                                    ),
                                  );
                            } catch (e) {
                              SnackBars.showErrorSnackBar(
                                context,
                                'Failed to get location: ${e.toString()}',
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: AppColors.greyLight,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.black),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextComponent(
                                labelText: TextConstants.proceedToRepark,
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Icon(
                                Icons.arrow_forward,
                                color: AppColors.black,
                                size: screenWidth * 0.05,
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),

            SizedBox(height: screenHeight * 0.015),

            // Cancel Button
            BlocBuilder<InitiateReparkBloc, InitiateReparkState>(
              builder: (context, state) {
                final isLoading = state is InitiateReparkLoading;
                return TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onCancel?.call();
                        },
                  child: TextComponent(
                    labelText: TextConstants.cancel,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: isLoading ? AppColors.greyLight : AppColors.grey,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
