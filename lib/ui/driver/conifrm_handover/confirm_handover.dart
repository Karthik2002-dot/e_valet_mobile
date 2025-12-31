import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niloufer_valet_mobile/api/driver/handover_api.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';

class ConfirmHandoverScreen extends StatefulWidget {
  final AssignedSession session;

  const ConfirmHandoverScreen({
    super.key,
    required this.session,
  });

  @override
  State<ConfirmHandoverScreen> createState() => _ConfirmHandoverScreenState();
}

class _ConfirmHandoverScreenState extends State<ConfirmHandoverScreen> {
  final List<TextEditingController> _controllers = List.generate(
    2,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    2,
    (_) => FocusNode(),
  );
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.04),

                    // Title
                    Text(
                      'Confirmation Handover',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Instruction Text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Text(
                        'Enter the 2-digit code provided by the user to complete the handover.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: AppColors.black,
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // 2-Digit Code Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                          child: _CodeInputField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 1) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Customer has no phone? Link
                    GestureDetector(
                      onTap: () {
                        // TODO: Handle customer has no phone
                        print('Customer has no phone clicked');
                      },
                      child: Text(
                        'Customer has no phone?',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AppColors.secondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
            ),
          ),

          // Buttons at bottom - always visible
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              children: [
                // Confirm Handover Button
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.07,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirmHandover,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.black,
                          )
                        : Text(
                            'Confirm Handover',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Customer Missing Button
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.07,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Handle customer missing
                      print('Customer Missing clicked');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      elevation: 0,
                      side: const BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          color: AppColors.error,
                          size: screenWidth * 0.06,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          'Customer Missing',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Icon(
                          Icons.arrow_forward,
                          color: AppColors.error,
                          size: screenWidth * 0.05,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirmHandover() async {
    if (_isLoading) return;

    // Get the 2-digit code
    final code = _controllers[0].text + _controllers[1].text;
    if (code.length != 2) {
      // Show error if code is not complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the 2-digit code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Confirm Handover clicked with code: $code');

      // Get stored current location (used for accept, arrived, handover)
      var locationData = await TokenStorage.getCurrentLocation();
      
      if (locationData == null) {
        // Fallback: Try arrival location for backward compatibility
        locationData = await TokenStorage.getArrivalLocation();
        
        if (locationData == null) {
          // Last resort: Get current location
          print('📍 No stored location found, getting current location...');
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
            final location = '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
            
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
              'Location permission is required to confirm handover',
              code: 'location_permission_denied',
            );
          }
        }
      }
      
      final latitude = locationData['latitude'] as double;
      final longitude = locationData['longitude'] as double;
      final location = locationData['location'] as String;
      
      print('📍 Using stored location: $location (lat: $latitude, lng: $longitude)');

      // Call handover API
      final response = await HandoverApiService.confirmHandover(
        sessionId: widget.session.id,
        latitude: latitude,
        longitude: longitude,
        location: location,
      );

      print('✅ Handover confirmed successfully: ${response.message}');

      if (mounted) {
        SnackBars.showSuccessSnackBar(context, response.message);
        // TODO: Navigate to next screen or close
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      print('❌ Handover API failed: ${e.message}');
      if (mounted) {
        SnackBars.showErrorSnackBar(context, e.message);
      }
    } catch (e) {
      print('❌ Error confirming handover: $e');
      if (mounted) {
        SnackBars.showErrorSnackBar(
          context,
          'Failed to confirm handover. Please try again.',
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

class _CodeInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _CodeInputField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isFocused = focusNode.hasFocus;

    return Container(
      width: screenWidth * 0.15,
      height: screenWidth * 0.15,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: isFocused ? AppColors.secondary : AppColors.primarySoft,
          width: isFocused ? 2 : 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: screenWidth * 0.08,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

