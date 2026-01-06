import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_event.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_reader_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_camera_screen.dart';

class DriverQrScannerContent extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const DriverQrScannerContent({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  State<DriverQrScannerContent> createState() => _DriverQrScannerContentState();
}

class _DriverQrScannerContentState extends State<DriverQrScannerContent> {
  final TextEditingController _tagNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _tagNumberController.dispose();
    super.dispose();
  }

  void _handleManualSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final tagNumber = _tagNumberController.text.trim();

      // Parse card number from tag number
      final cardNumber = int.tryParse(tagNumber);
      if (cardNumber == null) {
        // Show error if tag number is not a valid number
        SnackBars.showErrorSnackBar(
          context,
          TextConstants.validationEnterValidTagNumber,
        );
        return;
      }

      // Get outletId from DriverStatusBloc
      final statusState = context.read<DriverStatusBloc>().state;
      int outletId = 2; // Default fallback

      if (statusState is DriverStatusLoaded) {
        outletId = statusState.status.outletId;
      }

      context.read<TagSubmissionBloc>().add(
            TagNumberSubmitted(
              outletId: outletId,
              cardNumber: cardNumber,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrBloc(),
      child: MultiBlocListener(
        listeners: [
          // Listener for tag submission state
          BlocListener<TagSubmissionBloc, TagSubmissionState>(
            listener: (context, submissionState) {
              // Reset QR scanner and navigate to car camera screen after successful submission
              if (submissionState is TagSubmissionSuccess) {
                context.read<QrBloc>().add(const QrResetRequested());

                // Navigate to Car Camera Screen on success
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarCameraScreen(sessionId: null),
                  ),
                );
              } else if (submissionState is TagSubmissionError) {
                // Show error message
                SnackBars.showErrorSnackBar(
                  context,
                  submissionState.message,
                );
              }
            },
          ),
          // Listener for QR state to auto-submit when QR data is detected
          BlocListener<QrBloc, QrState>(
            listener: (context, qrState) {
              // Auto-submit when QR data is available
              if (qrState.qrData != null) {
                context.read<TagSubmissionBloc>().add(
                      QrCodeSubmitted(qrState.qrData!),
                    );
              }
            },
          ),
        ],
        child: Column(
          children: [
            // QR Scanner Area
            QrReaderWidget(
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
              isTablet: widget.isTablet,
              isDesktop: widget.isDesktop,
            ),
            SizedBox(height: widget.screenHeight * 0.02),

            // "Or Enter Key" text
            TextComponent(
              labelText: 'Or Enter Key',
              fontSize: widget.isDesktop
                  ? widget.screenWidth * 0.012
                  : widget.isTablet
                      ? widget.screenWidth * 0.02
                      : widget.screenWidth * 0.035,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: widget.screenHeight * 0.02),

            // Manual entry section
            Container(
              width: widget.screenWidth *
                  0.85, // Same width as QR reader container
              padding: EdgeInsets.all(widget.screenWidth * 0.025),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(widget.screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow10,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextComponent(
                        labelText: TextConstants.tagNumberLabel,
                        fontSize: widget.screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    TextFieldComponent(
                      labelText: TextConstants.emptyText,
                      hintText: TextConstants.tagNumberHint,
                      controller: _tagNumberController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return TextConstants.validationEnterTagNumber;
                        }
                        final cardNumber = int.tryParse(value.trim());
                        if (cardNumber == null) {
                          return TextConstants.validationEnterValidNumber;
                        }
                        return null;
                      },
                      borderRadius: widget.screenWidth * 0.03,
                    ),
                  ],
                ),
              ),
            ),

            // Small bottom spacing to keep submit button visible without scrolling
            SizedBox(height: widget.screenHeight * 0.03),

            // Manual entry submit button positioned at bottom
            Container(
              width: widget.screenWidth * 0.85, // Same width as containers
              margin: EdgeInsets.only(
                bottom: widget.screenHeight * 0.02, // Space above footer
              ),
              child: BlocBuilder<TagSubmissionBloc, TagSubmissionState>(
                builder: (context, submissionState) {
                  final isLoading = submissionState is TagSubmissionLoading;

                  return SizedBox(
                    height: widget.isDesktop
                        ? widget.screenHeight * 0.06
                        : widget.isTablet
                            ? widget.screenHeight * 0.07
                            : widget.screenHeight * 0.062,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleManualSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.greyLight,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(widget.screenWidth * 0.02),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: widget.isDesktop
                                  ? widget.screenWidth * 0.015
                                  : widget.isTablet
                                      ? widget.screenWidth * 0.025
                                      : widget.screenWidth * 0.045,
                              height: widget.isDesktop
                                  ? widget.screenWidth * 0.015
                                  : widget.isTablet
                                      ? widget.screenWidth * 0.025
                                      : widget.screenWidth * 0.045,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextComponent(
                                  labelText: TextConstants.submitButton,
                                  fontSize: widget.isDesktop
                                      ? widget.screenWidth * 0.014
                                      : widget.isTablet
                                          ? widget.screenWidth * 0.022
                                          : widget.screenWidth * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: widget.screenWidth * 0.02),
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.white,
                                  size: widget.isDesktop
                                      ? widget.screenWidth * 0.015
                                      : widget.isTablet
                                          ? widget.screenWidth * 0.025
                                          : widget.screenWidth * 0.045,
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
