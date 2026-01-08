import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_header.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_image_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_submit_button.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Success.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_state.dart';
import 'package:niloufer_valet_mobile/api/driver/assigned_sessions_api_service.dart';

class PreviewCarScreen extends StatefulWidget {
  final String imagePath;
  final String? sessionId;
  final bool isReparking;

  const PreviewCarScreen({
    super.key,
    required this.imagePath,
    this.sessionId,
    this.isReparking = false,
  });

  @override
  State<PreviewCarScreen> createState() => _PreviewCarScreenState();
}

class _PreviewCarScreenState extends State<PreviewCarScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Cancel existing timer if any
    _pollingTimer?.cancel();

    // Start polling every 2 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _pollAssignedSessions();
    });
  }

  Future<void> _pollAssignedSessions() async {
    try {
      final assignedSessions =
          await AssignedSessionsApiService.fetchAssignedSessions();

      // Only reflect/show data when we successfully get it
      _handleAssignedSessionsUpdate(assignedSessions);

      // Restart the timer when we get data
      _startPolling();
    } catch (e) {
      // Even on error, restart the timer to continue polling
      _startPolling();
    }
  }

  void _handleAssignedSessionsUpdate(List<dynamic> assignedSessions) {
    // Here you can update UI or perform actions only when data is received
    // For example: show a snackbar, update state, navigate, etc.
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => PreviewCarBloc(),
      child: BlocListener<PreviewCarBloc, PreviewCarState>(
        listener: (context, state) {
          if (state is PreviewCarSuccess) {
            // Navigate to success screen with the captured image
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => CarSuccessScreen(
                  imagePath: widget.imagePath,
                ),
              ),
            );
          } else if (state is PreviewCarError) {
            // Show error message
            SnackBars.showErrorSnackBar(
              context,
              state.message,
            );
          }
        },
        child: BlocBuilder<PreviewCarBloc, PreviewCarState>(
          builder: (context, state) {
            final isSubmitting = state is PreviewCarSubmitting;

            return Scaffold(
              backgroundColor: AppColors.lightBeigeBackground,
              appBar: const CustomAppBar(),
              body: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Review Entry Header
                        PreviewHeader(isReparking: widget.isReparking),
                        SizedBox(height: screenHeight * 0.02),

                        // Image Card with Retake Button
                        PreviewImageCard(
                          imagePath: widget.imagePath,
                          onRetake: () => Navigator.pop(context),
                        ),

                        const Spacer(),

                        // Submit Button
                        PreviewSubmitButton(
                          onSubmit: isSubmitting
                              ? () {}
                              : () => context.read<PreviewCarBloc>().add(
                                    SubmitPhotoRequested(widget.imagePath,
                                        sessionId: widget.sessionId,
                                        isReparking: widget.isReparking),
                                  ),
                          isReparking: widget.isReparking,
                        ),

                        // Footer with "Powered By" and logo
                        const Footer(),
                      ],
                    ),
                  ),

                  // Loading overlay when submitting
                  if (isSubmitting)
                    Container(
                      color: AppColors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
