import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/operator_header_widget.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_home/operator_scanner_widget.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class OperatorHomeContent extends StatelessWidget {
  final String operatorName;
  final bool isOnBreak;
  final bool isOnline;

  const OperatorHomeContent({
    super.key,
    required this.operatorName,
    required this.isOnBreak,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      backgroundColor: AppColors.lightBeigeBackground,
      body: Column(
        children: [
          // Header Section (responsive height, orange background) - extends to top
          OperatorHeaderWidget(
            operatorName: operatorName,
            isOnBreak: isOnBreak,
            isOnline: isOnline,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
          // Main Content Section with SafeArea
          Expanded(
            child: SafeArea(
              top: false,
              child: Container(
                color: AppColors.lightBeigeBackground,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        // Welcome message
                        TextComponent(
                          labelText:
                              TextConstants.readyToParkMessage(operatorName),
                          fontSize: isDesktop
                              ? screenWidth * 0.018
                              : isTablet
                                  ? screenWidth * 0.028
                                  : screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextComponent(
                          labelText: TextConstants.scanKeyTagInstruction,
                          fontSize: isDesktop
                              ? screenWidth * 0.012
                              : isTablet
                                  ? screenWidth * 0.02
                                  : screenWidth * 0.035,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        // Scanner Area
                        OperatorScannerWidget(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isTablet: isTablet,
                          isDesktop: isDesktop,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Manual entry link
                        GestureDetector(
                          onTap: () {
                            // TODO: Handle manual entry
                          },
                          child: TextComponent(
                            labelText: TextConstants.enterTagNumberLink,
                            fontSize: isDesktop
                                ? screenWidth * 0.012
                                : isTablet
                                    ? screenWidth * 0.02
                                    : screenWidth * 0.035,
                            fontWeight: FontWeight.w400,
                            color: AppColors.mutedText,
                            textAlign: TextAlign.center,
                            textDecoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: isDesktop
                              ? screenHeight * 0.06
                              : isTablet
                                  ? screenHeight * 0.07
                                  : screenHeight * 0.062,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Handle submit
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextComponent(
                                  labelText: TextConstants.submitButton,
                                  fontSize: isDesktop
                                      ? screenWidth * 0.014
                                      : isTablet
                                          ? screenWidth * 0.022
                                          : screenWidth * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.white,
                                  size: isDesktop
                                      ? screenWidth * 0.015
                                      : isTablet
                                          ? screenWidth * 0.025
                                          : screenWidth * 0.045,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Footer
          SafeArea(
            top: false,
            child: const Footer(),
          ),
        ],
      ),
    );
  }
}
