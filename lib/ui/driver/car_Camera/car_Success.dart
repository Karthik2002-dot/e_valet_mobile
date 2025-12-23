import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';

class CarSuccessScreen extends StatelessWidget {
  const CarSuccessScreen({super.key});

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
              child: Text(
                'Successfully Parked',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Car image (already has checkmark inside)
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/car.png',
                  width: screenWidth * 0.95,
                  height: screenHeight * 0.55,
                  fit: BoxFit.contain,
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
                    // Navigate back to home screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Return To Home',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
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

