import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/password_reset_otp/password_reset_otp_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/password_reset_otp/password_reset_otp_event.dart';
import 'package:niloufer_valet_mobile/bloc/password_reset_otp/password_reset_otp_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/elevated_button.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class NewPasswordStep extends StatefulWidget {
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
  State<NewPasswordStep> createState() => _NewPasswordStepState();
}

class _NewPasswordStepState extends State<NewPasswordStep> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordResetOtpBloc, PasswordResetOtpState>(
      builder: (context, state) {
        bool isPasswordValid = false;
        String? passwordError;

        if (state is PasswordResetOtpVerified) {
          isPasswordValid = state.isPasswordValid;
          passwordError = state.passwordError;
        } else if (state is PasswordResetOtpVerifiedWithError) {
          isPasswordValid = state.isPasswordValid;
          passwordError = state.passwordError;
        }

        return Column(
          children: [
            SizedBox(height: widget.size.height * 0.02),
            TextComponent(
              labelText: TextConstants.otpVerifiedSetPassword,
              fontSize: widget.size.width * 0.04,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: widget.size.height * 0.02),
            TextField(
              controller: widget.newPasswordController,
              obscureText: widget.obscureNewPassword,
              onChanged: (value) {
                context
                    .read<PasswordResetOtpBloc>()
                    .add(PasswordResetOtpNewPasswordChanged(value));
              },
              decoration: InputDecoration(
                labelText: TextConstants.newPasswordLabel,
                border: const OutlineInputBorder(),
                errorText: passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    widget.obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: widget.onToggleObscure,
                ),
              ),
            ),
            SizedBox(height: widget.size.height * 0.02),
            SizedBox(
              width: double.infinity,
              child: Opacity(
                opacity: (!widget.isResetting && isPasswordValid) ? 1.0 : 0.5,
                child: ElevatedButtonComponent(
                  labelText: widget.isResetting
                      ? TextConstants.submittingNewPassword
                      : TextConstants.submitNewPassword,
                  onPressed: (!widget.isResetting && isPasswordValid)
                      ? () {
                          context.read<PasswordResetOtpBloc>().add(
                                const PasswordResetOtpResetPasswordSubmitted(),
                              );
                        }
                      : () {},
                  elevatedButtonBackgroundColor: AppColors.accent,
                  radius: 8,
                  fontSize: 16,
                  fontColor: AppColors.white,
                  fontWeight: FontWeight.w600,
                  padding:
                      EdgeInsets.symmetric(vertical: widget.size.height * 0.02),
                  icon: Icon(
                    Icons.lock_reset,
                    color: AppColors.white,
                    size: widget.size.width * 0.05,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
