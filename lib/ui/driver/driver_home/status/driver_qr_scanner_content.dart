import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_event.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_state.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_reader_widget.dart';

class DriverQrScannerContent extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback? onSwitchToManualEntry;

  const DriverQrScannerContent({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
    this.onSwitchToManualEntry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrBloc(),
      child: BlocListener<TagSubmissionBloc, TagSubmissionState>(
        listener: (context, submissionState) {
          // Reset QR scanner after successful submission
          if (submissionState is TagSubmissionSuccess) {
            context.read<QrBloc>().add(const QrResetRequested());
          }
        },
        child: Column(
          children: [
            // QR Scanner Area
            QrReaderWidget(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              isTablet: isTablet,
              isDesktop: isDesktop,
            ),
            SizedBox(height: screenHeight * 0.02),
            // Switch to manual entry link
            if (onSwitchToManualEntry != null)
              GestureDetector(
                onTap: onSwitchToManualEntry,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              ),
            SizedBox(height: screenHeight * 0.02),
            // Submit Button
            BlocBuilder<QrBloc, QrState>(
              builder: (context, qrState) {
                return BlocBuilder<TagSubmissionBloc, TagSubmissionState>(
                  builder: (context, submissionState) {
                    final hasValidQrData = qrState.qrData != null;
                    final isLoading = submissionState is TagSubmissionLoading;

                    return SizedBox(
                      width: double.infinity,
                      height: isDesktop
                          ? screenHeight * 0.06
                          : isTablet
                              ? screenHeight * 0.07
                              : screenHeight * 0.062,
                      child: ElevatedButton(
                        onPressed: (hasValidQrData && !isLoading)
                            ? () {
                                context.read<TagSubmissionBloc>().add(
                                      QrCodeSubmitted(qrState.qrData!),
                                    );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.greyLight,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: isDesktop
                                    ? screenWidth * 0.015
                                    : isTablet
                                        ? screenWidth * 0.025
                                        : screenWidth * 0.045,
                                height: isDesktop
                                    ? screenWidth * 0.015
                                    : isTablet
                                        ? screenWidth * 0.025
                                        : screenWidth * 0.045,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Row(
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
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
