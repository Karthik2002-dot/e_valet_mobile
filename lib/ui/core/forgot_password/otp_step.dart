import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/password_reset_otp/password_reset_otp_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/password_reset_otp/password_reset_otp_event.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/elevated_button.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/otp_input.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class OtpStep extends StatelessWidget {
  final String phoneNumber;
  final bool isVerifying;
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final Size size;

  const OtpStep({
    super.key,
    required this.phoneNumber,
    required this.isVerifying,
    required this.otpController,
    required this.otpFocusNode,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextComponent(
          labelText: TextConstants.otpSentTo(phoneNumber),
          fontSize: size.width * 0.04,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: size.height * 0.03),
        OtpInput(
          length: 6,
          controller: otpController,
          focusNode: otpFocusNode,
          autoFocus: true,
          onChanged: (value) {
            context
                .read<PasswordResetOtpBloc>()
                .add(PasswordResetOtpChanged(value));
          },
          onCompleted: (value) {
            context
                .read<PasswordResetOtpBloc>()
                .add(PasswordResetOtpChanged(value));
          },
        ),
        SizedBox(height: size.height * 0.03),
        SizedBox(
          width: double.infinity,
          child: ElevatedButtonComponent(
            labelText: isVerifying
                ? TextConstants.verifyingOtp
                : TextConstants.verifyOtp,
            onPressed: () {
              if (!isVerifying) {
                context
                    .read<PasswordResetOtpBloc>()
                    .add(const PasswordResetOtpVerifySubmitted());
              }
            },
            elevatedButtonBackgroundColor: AppColors.accent,
            radius: 8,
            fontSize: 16,
            fontColor: AppColors.white,
            fontWeight: FontWeight.w600,
            padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
            icon: Icon(
              Icons.verified_user_outlined,
              color: AppColors.white,
              size: size.width * 0.05,
            ),
          ),
        ),
      ],
    );
  }
}
