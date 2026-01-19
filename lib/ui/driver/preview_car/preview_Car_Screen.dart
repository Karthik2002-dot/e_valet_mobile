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
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

class PreviewCarScreen extends StatefulWidget {
  final String imagePath;
  final String? sessionId;
  final bool isReparking;
  final String? parkingLocation;

  const PreviewCarScreen({
    super.key,
    required this.imagePath,
    this.sessionId,
    this.isReparking = false,
    this.parkingLocation,
  });

  @override
  State<PreviewCarScreen> createState() => _PreviewCarScreenState();
}

class _PreviewCarScreenState extends State<PreviewCarScreen> {
  Timer? _pollingTimer;
  String? _currentParkingLocation;

  @override
  void initState() {
    super.initState();
    _currentParkingLocation = widget.parkingLocation;
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

  Future<void> _handleSubmit(BuildContext context) async {
    try {
      // Get current GPS location
      final coordinates = await LocationService.getCurrentCoordinates();

      // Submit with GPS data
      context.read<PreviewCarBloc>().add(
            SubmitPhotoRequested(
              imagePath: (widget.parkingLocation == null ||
                      widget.parkingLocation!.isEmpty)
                  ? widget.imagePath
                  : null,
              sessionId: widget.sessionId,
              isReparking: widget.isReparking,
              latitude: coordinates['latitude']!,
              longitude: coordinates['longitude']!,
              accuracy: coordinates['accuracy'],
              parkingLocation: _currentParkingLocation,
            ),
          );
    } on ApiException catch (e) {
      // Show error if GPS location cannot be obtained
      SnackBars.showErrorSnackBar(context, e.message);
    } catch (e) {
      SnackBars.showErrorSnackBar(
        context,
        'Failed to get location. Please try again.',
      );
    }
  }

  void _showEditParkingLocationDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final TextEditingController editController = TextEditingController(
      text: _currentParkingLocation ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Parking Location',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: editController,
            autofocus: true,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
            ),
            decoration: InputDecoration(
              hintText: 'Enter parking location...',
              hintStyle: TextStyle(
                color: AppColors.grey.withOpacity(0.6),
                fontSize: screenWidth * 0.04,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: screenWidth * 0.038,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newLocation = editController.text.trim();
                if (newLocation.isNotEmpty) {
                  setState(() {
                    _currentParkingLocation = newLocation;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter parking location'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                ),
              ),
            ),
          ],
        );
      },
    );
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

                        // Parking Location Display (if provided)
                        if (widget.parkingLocation != null &&
                            widget.parkingLocation!.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            margin:
                                EdgeInsets.only(bottom: screenHeight * 0.02),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: AppColors.primary,
                                          size: screenWidth * 0.05,
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(
                                          'Parking Location',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Edit Icon Button
                                    InkWell(
                                      onTap: _showEditParkingLocationDialog,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(screenWidth * 0.02),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: AppColors.primary,
                                          size: screenWidth * 0.045,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  _currentParkingLocation ??
                                      widget.parkingLocation ??
                                      '',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.038,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Image Card with Retake Button - Only show if parking location is NOT provided (normal photo flow)
                        if (widget.parkingLocation == null ||
                            widget.parkingLocation!.isEmpty)
                          PreviewImageCard(
                            imagePath: widget.imagePath,
                            onRetake: () => Navigator.pop(context),
                          ),

                        const Spacer(),

                        // Submit Button
                        PreviewSubmitButton(
                          onSubmit: isSubmitting
                              ? () {}
                              : () => _handleSubmit(context),
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
