import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class QrStatusDisplayWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const QrStatusDisplayWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QrBloc, QrState>(
      builder: (context, state) {
        final scanned = state.scannedCode;
        final isProcessing = state.isProcessing;
        final successMsg = state.successMessage;
        final errorMsg = state.errorMessage;

        if (isProcessing && scanned != null) {
          return _buildProcessingWidget(scanned);
        }

        if (successMsg != null && scanned != null) {
          return _buildSuccessWidget(successMsg, scanned);
        }

        if (errorMsg != null && scanned != null) {
          return _buildErrorWidget(errorMsg, scanned);
        }

        if (scanned != null && !isProcessing) {
          return _buildScannedDataWidget(scanned);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProcessingWidget(String scanned) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(
          color: AppColors.primary,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isDesktop
                    ? screenWidth * 0.02
                    : isTablet
                        ? screenWidth * 0.03
                        : screenWidth * 0.05,
                height: isDesktop
                    ? screenWidth * 0.02
                    : isTablet
                        ? screenWidth * 0.03
                        : screenWidth * 0.05,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              TextComponent(
                labelText: TextConstants.processingQrCode,
                fontSize: isDesktop
                    ? screenWidth * 0.012
                    : isTablet
                        ? screenWidth * 0.018
                        : screenWidth * 0.03,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.01),
            ),
            child: TextComponent(
              labelText: scanned,
              fontSize: isDesktop
                  ? screenWidth * 0.011
                  : isTablet
                      ? screenWidth * 0.016
                      : screenWidth * 0.028,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessWidget(String successMsg, String scanned) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: AppColors.qrSuccessBackground,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(
          color: AppColors.qrSuccessBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.qrSuccessText,
                size: isDesktop
                    ? screenWidth * 0.025
                    : isTablet
                        ? screenWidth * 0.04
                        : screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                child: TextComponent(
                  labelText: successMsg,
                  fontSize: isDesktop
                      ? screenWidth * 0.012
                      : isTablet
                          ? screenWidth * 0.018
                          : screenWidth * 0.03,
                  fontWeight: FontWeight.w600,
                  color: AppColors.qrSuccessText,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.01),
              border: Border.all(
                color: AppColors.qrSuccessBorderLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextComponent(
                  labelText: TextConstants.scannedDataLabel,
                  fontSize: isDesktop
                      ? screenWidth * 0.01
                      : isTablet
                          ? screenWidth * 0.015
                          : screenWidth * 0.025,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: screenHeight * 0.005),
                TextComponent(
                  labelText: scanned,
                  fontSize: isDesktop
                      ? screenWidth * 0.012
                      : isTablet
                          ? screenWidth * 0.018
                          : screenWidth * 0.032,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMsg, String scanned) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: AppColors.qrErrorBackground,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(
          color: AppColors.error,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: isDesktop
                    ? screenWidth * 0.025
                    : isTablet
                        ? screenWidth * 0.04
                        : screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: TextComponent(
                  labelText: TextConstants.errorProcessingQrCode,
                  fontSize: isDesktop
                      ? screenWidth * 0.012
                      : isTablet
                          ? screenWidth * 0.018
                          : screenWidth * 0.03,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.01),
            ),
            child: Column(
              children: [
                TextComponent(
                  labelText: '${TextConstants.scannedLabel} $scanned',
                  fontSize: isDesktop
                      ? screenWidth * 0.01
                      : isTablet
                          ? screenWidth * 0.015
                          : screenWidth * 0.025,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.005),
                TextComponent(
                  labelText: errorMsg,
                  fontSize: isDesktop
                      ? screenWidth * 0.01
                      : isTablet
                          ? screenWidth * 0.015
                          : screenWidth * 0.025,
                  fontWeight: FontWeight.w400,
                  color: AppColors.error,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedDataWidget(String scanned) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(
          color: AppColors.primary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextComponent(
            labelText: TextConstants.scannedDataLabel,
            fontSize: isDesktop
                ? screenWidth * 0.012
                : isTablet
                    ? screenWidth * 0.018
                    : screenWidth * 0.03,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: screenHeight * 0.01),
          TextComponent(
            labelText: scanned,
            fontSize: isDesktop
                ? screenWidth * 0.014
                : isTablet
                    ? screenWidth * 0.02
                    : screenWidth * 0.035,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
