import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/password_reset_otp/password_reset_otp_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/password_reset_otp/password_reset_otp_event.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/elevated_button.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class NewPasswordStep extends StatelessWidget {
  final bool isResetting;
  final TextEditingController newPasswordController;
  final bool obscureNewPassword;
  final VoidCallback onToggleObscure;
  final Size size;

  const NewPasswordStep({
    super.key,
    required this.isResetting,
    required this.newPasswordController,
    required this.obscureNewPassword,
    required this.onToggleObscure,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),
        TextComponent(
          labelText: TextConstants.otpVerifiedSetPassword,
          fontSize: size.width * 0.04,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: size.height * 0.02),
        TextField(
          controller: newPasswordController,
          obscureText: obscureNewPassword,
          onChanged: (value) {
            context
                .read<PasswordResetOtpBloc>()
                .add(PasswordResetOtpNewPasswordChanged(value));
          },
          decoration: InputDecoration(
            labelText: TextConstants.newPasswordLabel,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                obscureNewPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.02),
        SizedBox(
          width: double.infinity,
          child: ElevatedButtonComponent(
            labelText: isResetting
                ? TextConstants.submittingNewPassword
                : TextConstants.submitNewPassword,
            onPressed: () {
              if (!isResetting) {
                context.read<PasswordResetOtpBloc>().add(
                      const PasswordResetOtpResetPasswordSubmitted(),
                    );
              }
            },
            elevatedButtonBackgroundColor: AppColors.accent,
            radius: 8,
            fontSize: 16,
            fontColor: AppColors.white,
            fontWeight: FontWeight.w600,
            padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
            icon: Icon(
              Icons.lock_reset,
              color: AppColors.white,
              size: size.width * 0.05,
            ),
          ),
        ),
      ],
    );
  }
}
