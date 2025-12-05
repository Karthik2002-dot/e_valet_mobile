import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/texts.dart';

class QrScreenContent extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const QrScreenContent({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const TextComponent(
                labelText: AppTexts.welcomeTitle,
                fontSize: 18,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const TextComponent(
                labelText: AppTexts.welcomeSubtitle,
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  child: Image.asset(
                    'assets/images/qr.png',
                    width: screenWidth * 0.65,
                    height: screenWidth * 0.65,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              TextComponent(
                labelText: AppTexts.qrInstruction,
                fontSize: screenWidth * 0.035,
                color: AppColors.black,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
