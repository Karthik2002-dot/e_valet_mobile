import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class CarSuccessScreen extends StatefulWidget {
  final String? imagePath;
  final bool isLocationBasedParking;

  const CarSuccessScreen({
    super.key,
    this.imagePath,
    this.isLocationBasedParking = false,
  });

  @override
  State<CarSuccessScreen> createState() => _CarSuccessScreenState();
}

class _CarSuccessScreenState extends State<CarSuccessScreen> {
  bool _isReturningHome = false;
  Timer? _autoReturnTimer;

  static const Duration _autoReturnDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    // After a successful park, the previous "pending session" id must be cleared.
    // Otherwise, the pending-session watchdog in `DriverOnlineContent` will detect
    // it as "cancelled" on the next Park attempt and pop the user back to Home.
    TokenStorage.clearSessionId();
    TokenStorage.clearSessionIdFromGetApi();
    _autoReturnTimer = Timer(_autoReturnDuration, _navigateToHome);
  }

  void _navigateToHome() {
    _autoReturnTimer?.cancel();
    _autoReturnTimer = null;
    if (!mounted) return;
    setState(() => _isReturningHome = true);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const DriverHomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _autoReturnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine background color and image to show
    final backgroundColor = widget.isLocationBasedParking
        ? AppColors.headerYellow
        : AppColors.primary;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Successfully Parked text
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.06,
                  bottom: screenHeight * 0.04,
                ),
                child: TextComponent(
                  labelText: t.get(TextConstants.successfullyParked),
                  color: AppColors.white,
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Car image - show car.png for location-based parking, otherwise show captured image
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    child: widget.isLocationBasedParking
                        ? // Show car.png image with full display (no cropping)
                        Image.asset(
                            'assets/images/car.png',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          )
                        : // Show captured image for normal photo flow
                        (widget.imagePath != null
                            ? Image.file(
                                File(widget.imagePath!),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to static logo if image loading fails
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.04),
                                    child: Image.asset(
                                      'assets/images/car.png',
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              )
                            : // Fallback if no image path provided
                            Image.asset(
                                'assets/images/car.png',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                              )),
                  ),
                ),
              ),

              // Return To Home button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1,
                  vertical: screenHeight * 0.03,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.07,
                  child: ElevatedButton(
                    onPressed: _isReturningHome
                        ? null
                        : () {
                            _autoReturnTimer?.cancel();
                            _autoReturnTimer = null;
                            _navigateToHome();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      elevation: 0,
                    ),
                    child: _isReturningHome
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.black),
                            ),
                          )
                        : TextComponent(
                            labelText: t.get(TextConstants.returnToHome),
                            color: AppColors.black,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ),
              ),

              // Footer
              const Footer(),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
