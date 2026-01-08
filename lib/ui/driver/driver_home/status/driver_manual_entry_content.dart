import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_camera_screen.dart';

class DriverManualEntryContent extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback? onSwitchToQrScanner;

  const DriverManualEntryContent({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
    this.onSwitchToQrScanner,
  });

  @override
  State<DriverManualEntryContent> createState() =>
      _DriverManualEntryContentState();
}

class _DriverManualEntryContentState extends State<DriverManualEntryContent> {
  final TextEditingController _tagNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _tagNumberController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
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
    final w = widget.screenWidth;
    final h = widget.screenHeight;

    return BlocListener<TagSubmissionBloc, TagSubmissionState>(
      listener: (context, state) {
        if (state is TagSubmissionSuccess) {
          // Navigate to Car Camera Screen on success
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarCameraScreen(sessionId: null),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card with icon + title + input
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(w * 0.06),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(w * 0.04),
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
                  SvgPicture.asset(
                    'assets/svg/key_handover.svg',
                    width: w * 0.2,
                    height: w * 0.2,
                  ),
                  SizedBox(height: h * 0.02),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextComponent(
                      labelText: TextConstants.tagNumberLabel,
                      fontSize: w * 0.035,
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
                    borderRadius: w * 0.03,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: h * 0.025),

          // Submit button (outside card)
          BlocBuilder<TagSubmissionBloc, TagSubmissionState>(
            builder: (context, state) {
              final isLoading = state is TagSubmissionLoading;

              return SizedBox(
                width: double.infinity,
                height: widget.isDesktop
                    ? h * 0.06
                    : widget.isTablet
                        ? h * 0.07
                        : h * 0.062,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.greyLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.02),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: widget.isDesktop
                              ? w * 0.015
                              : widget.isTablet
                                  ? w * 0.025
                                  : w * 0.045,
                          height: widget.isDesktop
                              ? w * 0.015
                              : widget.isTablet
                                  ? w * 0.025
                                  : w * 0.045,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextComponent(
                              labelText: TextConstants.submitButton,
                              fontSize: widget.isDesktop
                                  ? w * 0.014
                                  : widget.isTablet
                                      ? w * 0.022
                                      : w * 0.04,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                            SizedBox(width: w * 0.02),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.white,
                              size: widget.isDesktop
                                  ? w * 0.015
                                  : widget.isTablet
                                      ? w * 0.025
                                      : w * 0.045,
                            ),
                          ],
                        ),
                ),
              );
            },
          ),

          SizedBox(height: h * 0.015),

          // "Or scan the tag number" link (also outside card)
          if (widget.onSwitchToQrScanner != null)
            GestureDetector(
              onTap: widget.onSwitchToQrScanner,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextComponent(
                  labelText: TextConstants.scanTagNumberLink,
                  // e.g. "Or scan the tag number"
                  fontSize: widget.isDesktop
                      ? w * 0.012
                      : widget.isTablet
                          ? w * 0.02
                          : w * 0.035,
                  fontWeight: FontWeight.w400,
                  color: AppColors.mutedText,
                  textAlign: TextAlign.center,
                  textDecoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
