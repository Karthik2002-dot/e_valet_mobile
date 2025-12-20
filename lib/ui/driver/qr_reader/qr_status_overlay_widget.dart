import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_event.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class QrStatusOverlayWidget extends StatelessWidget {
  final QrState state;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const QrStatusOverlayWidget({
    super.key,
    required this.state,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = state.qrData != null;

    // Brighter colors for better visibility
    final successColor = const Color(0xFF10B981); // Bright green
    final errorColor = const Color(0xFFEF4444); // Bright red
    final successBg = const Color(0xFFECFDF5); // Light green background
    final errorBg = const Color(0xFFFEF2F2); // Light red background

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        color: isSuccess ? successBg : errorBg,
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        border: Border.all(
          color: isSuccess ? successColor : errorColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSuccess ? successColor : errorColor).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and message row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.015),
                decoration: BoxDecoration(
                  color: isSuccess ? successColor : errorColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_rounded : Icons.close_rounded,
                  color: AppColors.white,
                  size: isDesktop
                      ? screenWidth * 0.025
                      : isTablet
                          ? screenWidth * 0.035
                          : screenWidth * 0.05,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                child: Text(
                  isSuccess
                      ? TextConstants.scannedSuccess
                      : (state.errorMessage ?? TextConstants.errorLabel),
                  style: TextStyle(
                    fontSize: isDesktop
                        ? screenWidth * 0.012
                        : isTablet
                            ? screenWidth * 0.018
                            : screenWidth * 0.026,
                    fontWeight: FontWeight.w700,
                    color: isSuccess ? successColor : errorColor,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Card number display (only for success)
          if (isSuccess && state.qrData != null) ...[
            SizedBox(height: screenHeight * 0.015),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenHeight * 0.012,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.015),
                border: Border.all(
                  color: successColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: successColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextComponent(
                    labelText: TextConstants.cardLabel,
                    fontSize: isDesktop
                        ? screenWidth * 0.014
                        : isTablet
                            ? screenWidth * 0.02
                            : screenWidth * 0.028,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                  TextComponent(
                    labelText: state.qrData!.cardNumber.toString(),
                    fontSize: isDesktop
                        ? screenWidth * 0.018
                        : isTablet
                            ? screenWidth * 0.026
                            : screenWidth * 0.038,
                    fontWeight: FontWeight.w800,
                    color: successColor,
                  ),
                ],
              ),
            ),
          ],
          // Rescan button
          SizedBox(height: screenHeight * 0.015),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<QrBloc>().add(const QrResetRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? successColor : errorColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.012),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: TextComponent(
                labelText: TextConstants.rescanButton,
                fontSize: isDesktop
                    ? screenWidth * 0.011
                    : isTablet
                        ? screenWidth * 0.016
                        : screenWidth * 0.022,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
