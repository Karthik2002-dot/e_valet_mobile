import 'dart:io';
import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home.dart';

class CarSuccessScreen extends StatelessWidget {
  final String imagePath;

  const CarSuccessScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primary,
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
                labelText: TextConstants.successfullyParked,
                color: AppColors.white,
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Captured car image with rounded corners
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  child: Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to static logo if image loading fails
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        child: Image.asset(
                          'assets/images/car.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Return To Home button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.15,
                vertical: screenHeight * 0.03,
              ),
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the driver home and show the retrieval sheet
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const DriverHomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    elevation: 0,
                  ),
                  child: TextComponent(
                    labelText: TextConstants.returnToHome,
                    color: AppColors.black,
                    fontSize: screenWidth * 0.04,
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
    );
  }
}
