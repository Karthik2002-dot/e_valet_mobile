import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_header.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_image_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_submit_button.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Success.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_state.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

class PreviewCarScreen extends StatefulWidget {
  /// Photo path when coming from Scan; null when coming from Type Parking Number only.
  final String? imagePath;
  final String? sessionId;
  final bool isReparking;
  final String? parkingLocation;
  final String? vehicleNumber;

  const PreviewCarScreen({
    super.key,
    this.imagePath,
    this.sessionId,
    this.isReparking = false,
    this.parkingLocation,
    this.vehicleNumber,
  });

  @override
  State<PreviewCarScreen> createState() => _PreviewCarScreenState();
}

class _PreviewCarScreenState extends State<PreviewCarScreen> {
  String? _currentParkingLocation;
  String? _currentVehicleNumber;

  /// Parking location input when in photo flow (captured image); required before Done.
  late final TextEditingController _parkingLocationController;

  /// Prevents multiple rapid taps from triggering duplicate submissions
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentParkingLocation = widget.parkingLocation;
    _currentVehicleNumber = widget.vehicleNumber;
    _parkingLocationController = TextEditingController(
      text: widget.parkingLocation ?? '',
    );
    _parkingLocationController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _parkingLocationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(BuildContext context) async {
    // Guard: prevent multiple rapid taps immediately
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Get current GPS location
      final coordinates = await LocationService.getCurrentCoordinates();

      if (!context.mounted) return;

      // Use controller text for parking location when in photo flow
      final parkingLocation = _parkingLocationController.text.trim().isNotEmpty
          ? _parkingLocationController.text.trim()
          : _currentParkingLocation;

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
              parkingLocation: parkingLocation,
              vehicleNumber: _currentVehicleNumber,
            ),
          );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      setState(() => _isProcessing = false);
      SnackBars.showErrorSnackBar(context, e.message);
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isProcessing = false);
      SnackBars.showErrorSnackBar(
        context,
        'Failed to get location. Please try again.',
      );
    }
  }

  void _showEditDetailsDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final locationController = TextEditingController(
      text: _currentParkingLocation ?? '',
    );
    final vehicleController = TextEditingController(
      text: _currentVehicleNumber ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit details',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Parking Location',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 6),
                TextField(
                  controller: locationController,
                  autofocus: true,
                  style: TextStyle(fontSize: screenWidth * 0.04),
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
                SizedBox(height: 16),
                Text(
                  'Vehicle Number',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 6),
                TextField(
                  controller: vehicleController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: TextStyle(fontSize: screenWidth * 0.04),
                  decoration: InputDecoration(
                    hintText: 'Enter vehicle number...',
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
                ),
              ],
            ),
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
                final newLocation = locationController.text.trim();
                final newVehicle = vehicleController.text.trim();
                if (newLocation.isNotEmpty) {
                  setState(() {
                    _currentParkingLocation = newLocation;
                    _currentVehicleNumber =
                        newVehicle.isEmpty ? null : newVehicle;
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
                style: TextStyle(fontSize: screenWidth * 0.038),
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
            // Navigate to success screen
            // If parking was done via location input, show car.png with golden background
            final isLocationBased = widget.parkingLocation != null &&
                widget.parkingLocation!.isNotEmpty;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => CarSuccessScreen(
                  imagePath: isLocationBased ? null : widget.imagePath,
                  isLocationBasedParking: isLocationBased,
                ),
              ),
            );
          } else if (state is PreviewCarError) {
            setState(() => _isProcessing = false);
            SnackBars.showErrorSnackBar(
              context,
              state.message,
            );
          }
        },
        child: BlocBuilder<PreviewCarBloc, PreviewCarState>(
          builder: (context, state) {
            final isSubmitting = state is PreviewCarSubmitting || _isProcessing;

            final horizontalPadding = screenWidth * 0.04;
            final isReviewEntry = widget.parkingLocation != null &&
                widget.parkingLocation!.isNotEmpty;
            final isPhotoFlow = (widget.parkingLocation == null ||
                    widget.parkingLocation!.isEmpty) &&
                widget.imagePath != null &&
                widget.imagePath!.isNotEmpty;
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return Scaffold(
              backgroundColor: AppColors.lightBeigeBackground,
              appBar: const CustomAppBar(),
              resizeToAvoidBottomInset: true,
              body: isPhotoFlow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(
                              left: horizontalPadding,
                              right: horizontalPadding,
                              top: horizontalPadding,
                              bottom: horizontalPadding + bottomInset + 24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PreviewHeader(isReparking: widget.isReparking),
                                SizedBox(height: screenHeight * 0.02),
                                PreviewImageCard(
                                  imagePath: widget.imagePath!,
                                  onRetake: () => Navigator.pop(context),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextFieldComponent(
                                    labelText:
                                        TextConstants.parkingLocationLabel,
                                    hintText: TextConstants.parkingLocationHint,
                                    controller: _parkingLocationController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    fontSize: screenWidth * 0.04,
                                    labelFontSize: screenWidth * 0.04,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                      vertical: screenHeight * 0.018,
                                    ),
                                    borderRadius: 8,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                PreviewSubmitButton(
                                  onSubmit: () => _handleSubmit(context),
                                  isReparking: widget.isReparking,
                                  isLoading: isSubmitting,
                                  isEnabled: _parkingLocationController.text
                                      .trim()
                                      .isNotEmpty,
                                  overrideLabel:
                                      TextConstants.previewDoneButton,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SafeArea(
                          top: false,
                          child: const Footer(),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: horizontalPadding,
                            bottom: isReviewEntry ? 0.0 : horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PreviewHeader(isReparking: widget.isReparking),
                              SizedBox(height: screenHeight * 0.02),

                              // Parking Location Display (if provided) - container expands till bottom of screen, OK button inside at bottom
                              if (widget.parkingLocation != null &&
                                  widget.parkingLocation!.isNotEmpty)
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(screenWidth * 0.04),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                SizedBox(
                                                    width: screenWidth * 0.02),
                                                Text(
                                                  'Parking Location',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Edit Icon Button
                                            InkWell(
                                              onTap: _showEditDetailsDialog,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    screenWidth * 0.02),
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
                                        if (_currentVehicleNumber != null &&
                                            _currentVehicleNumber!
                                                .isNotEmpty) ...[
                                          SizedBox(
                                              height: screenHeight * 0.012),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.directions_car,
                                                color: AppColors.primary,
                                                size: screenWidth * 0.045,
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.02),
                                              Text(
                                                'Vehicle Number',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.035,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.004),
                                          Text(
                                            _currentVehicleNumber!,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.038,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ],
                                        // Instruction text below vehicle number (with gap)
                                        SizedBox(height: screenHeight * 0.025),
                                        Text(
                                          'After the vehicle is successfully parked, please press the button below to confirm.',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            color: AppColors.black,
                                            height: 1.35,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: screenHeight * 0.02),
                                        // OK button expands from here to the bottom of the screen
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: isSubmitting
                                                  ? null
                                                  : () =>
                                                      _handleSubmit(context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          screenWidth * 0.028),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: isSubmitting
                                                  ? SizedBox(
                                                      width: 32,
                                                      height: 32,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                AppColors
                                                                    .white),
                                                      ),
                                                    )
                                                  : Text(
                                                      'OK',
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.02),
                                      ],
                                    ),
                                  ),
                                ),

                              // When review entry: container expands to screen bottom only (no footer below)
                              if (!isReviewEntry) const Spacer(),

                              // Footer only when NOT review entry (so container can expand till screen bottom)
                              if (!isReviewEntry) const Footer(),
                            ],
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
