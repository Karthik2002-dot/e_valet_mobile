import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niloufer_valet_mobile/api/driver/arrived_api.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/conifrm_handover/confirm_handover.dart';

class ConfirmArrivalScreen extends StatefulWidget {
  final AssignedSession session;

  const ConfirmArrivalScreen({
    super.key,
    required this.session,
  });

  @override
  State<ConfirmArrivalScreen> createState() => _ConfirmArrivalScreenState();
}

class _ConfirmArrivalScreenState extends State<ConfirmArrivalScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.lightBeigeBackground,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    // Title
                    Center(
                      child: Text(
                        'Retrieval Request',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Car Information Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow10,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Car Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: Image(
                              image: widget.session.photoUrl != null
                                  ? NetworkImage(widget.session.photoUrl!)
                                  : const AssetImage('assets/images/car.png')
                                      as ImageProvider,
                              width: double.infinity,
                              height: screenWidth * 0.6,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/car.png',
                                  width: double.infinity,
                                  height: screenWidth * 0.6,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),

                          // Details Section
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Badge Number
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      size: screenWidth * 0.06,
                                      color: AppColors.secondary,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Badge Number',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.005),
                                          Text(
                                            widget.session.cardNumber
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.05,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.02),

                                Divider(
                                  color: AppColors.greyLight,
                                  thickness: 1,
                                  height: 1,
                                ),

                                SizedBox(height: screenHeight * 0.02),

                                // Parked By
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.badge,
                                      size: screenWidth * 0.06,
                                      color: AppColors.secondary,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Parked By',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.005),
                                          Text(
                                            widget.session.parkedBy?.name ??
                                                'Unknown',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Phone Icon
                                    IconButton(
                                      onPressed: () {
                                        // TODO: Implement phone call functionality
                                      },
                                      icon: Icon(
                                        Icons.phone,
                                        color: AppColors.secondary,
                                        size: screenWidth * 0.06,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.02),

                                // Locate Car Button
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.greyLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.remove_red_eye,
                                        size: screenWidth * 0.05,
                                        color: AppColors.secondary,
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        'LOCATE CAR USING THE PHOTO',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Slide to Confirm Arrival Button at Bottom
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: _SlideToConfirmButton(
              sessionId: widget.session.id,
              isLoading: _isLoading,
              onConfirm: _handleConfirmArrival,
            ),
          ),

          // Footer at Bottom
          const Footer(),
        ],
      ),
    );
  }

  Future<void> _handleConfirmArrival() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get stored location or fetch new one
      var locationData = await TokenStorage.getCurrentLocation();

      if (locationData == null) {
        // Request permission if needed
        LocationPermission permission = await LocationService.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await LocationService.requestPermission();
        }

        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final position = await LocationService.getCurrentLocation();
          final latitude = position.latitude;
          final longitude = position.longitude;
          final location =
              '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

          locationData = {
            'latitude': latitude,
            'longitude': longitude,
            'location': location,
          };

          // Save for future use
          await TokenStorage.saveCurrentLocation(
            latitude: latitude,
            longitude: longitude,
            location: location,
          );
        } else {
          throw ApiException(
            'Location permission is required to confirm arrival',
            code: 'location_permission_denied',
          );
        }
      }

      final latitude = locationData['latitude'] as double;
      final longitude = locationData['longitude'] as double;
      final location = locationData['location'] as String;

      final response = await ArrivedApiService.confirmArrival(
        sessionId: widget.session.id,
        latitude: latitude,
        longitude: longitude,
        location: location,
      );

      // Store location for handover API (keeping for backward compatibility)
      await TokenStorage.saveArrivalLocation(
        latitude: latitude,
        longitude: longitude,
        location: location,
      );

      if (mounted) {
        SnackBars.showSuccessSnackBar(context, response.message);
        // Navigate to confirm handover screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ConfirmHandoverScreen(session: widget.session),
          ),
        );
      }
    } on ApiException catch (e) {
      print('❌ Arrival API failed: ${e.message}');

      // If session is already ARRIVED, treat it as success
      if (e.message.contains('ARRIVED') &&
          e.message.contains('expected RETRIEVING')) {
        if (mounted) {
          SnackBars.showSuccessSnackBar(
            context,
            'Arrival already confirmed. Session is ready for handover.',
          );
          // Navigate to confirm handover screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  ConfirmHandoverScreen(session: widget.session),
            ),
          );
        }
      } else {
        if (mounted) {
          SnackBars.showErrorSnackBar(context, e.message);
        }
      }
    } catch (e) {
      print('❌ Error confirming arrival: $e');
      if (mounted) {
        SnackBars.showErrorSnackBar(
          context,
          'Failed to confirm arrival. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _SlideToConfirmButton extends StatefulWidget {
  final String sessionId;
  final bool isLoading;
  final VoidCallback onConfirm;

  const _SlideToConfirmButton({
    required this.sessionId,
    required this.isLoading,
    required this.onConfirm,
  });

  @override
  State<_SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<_SlideToConfirmButton> {
  double _dragPosition = 0.0;
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonHeight = screenHeight * 0.07;
    final maxDrag = screenWidth - buttonHeight - 32; // 32 is padding

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (!_isConfirmed && !widget.isLoading) {
          setState(() {
            _dragPosition =
                (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
            if (_dragPosition >= maxDrag * 0.9) {
              _isConfirmed = true;
              widget.onConfirm();
            }
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (!_isConfirmed && !widget.isLoading) {
          setState(() {
            _dragPosition = 0.0;
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow10,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Text
            Center(
              child: widget.isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Slide to Confirm Arrival',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
            ),
            // Slidable button
            Positioned(
              left: _dragPosition,
              child: Container(
                width: buttonHeight,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward,
                        color: AppColors.white,
                        size: screenWidth * 0.06,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
