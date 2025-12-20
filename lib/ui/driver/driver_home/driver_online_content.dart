import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_reader_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_status_display_widget.dart';

class DriverOnlineContent extends StatelessWidget {
  final String driverName;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const DriverOnlineContent({
    super.key,
    required this.driverName,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.03),
        // Welcome message
        TextComponent(
          labelText: TextConstants.readyToParkMessage(driverName),
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
        // Scanner Area with dedicated QR bloc
        BlocProvider(
          create: (_) => QrBloc(),
          child: Column(
            children: [
              QrReaderWidget(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isTablet: isTablet,
                isDesktop: isDesktop,
              ),
              SizedBox(height: screenHeight * 0.02),
              // Display processing status and QR code data
              QrStatusDisplayWidget(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isTablet: isTablet,
                isDesktop: isDesktop,
              ),
            ],
          ),
        ),
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
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
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
    );
  }
}
