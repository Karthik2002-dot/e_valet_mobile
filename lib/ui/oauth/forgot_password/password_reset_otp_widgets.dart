import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/oauth/forgot_password/new_password_step.dart';
import 'package:niloufer_valet_mobile/ui/oauth/forgot_password/otp_step.dart';

/// Card wrapper that decides which step to show.
class PasswordResetOtpCard extends StatelessWidget {
  final bool isOtpVerified;
  final String phoneNumber;
  final bool isVerifying;
  final bool isResetting;
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final TextEditingController newPasswordController;
  final bool obscureNewPassword;
  final VoidCallback onToggleObscure;
  final String? errorMessage;

  const PasswordResetOtpCard({
    super.key,
    required this.isOtpVerified,
    required this.phoneNumber,
    required this.isVerifying,
    required this.isResetting,
    required this.otpController,
    required this.otpFocusNode,
    required this.newPasswordController,
    required this.obscureNewPassword,
    required this.onToggleObscure,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: size.width * 1),
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(size.width * 0.05),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mark_email_unread_outlined,
            color: AppColors.black,
            size: size.width * 0.2,
          ),
          SizedBox(height: size.height * 0.02),
          TextComponent(
            labelText: isOtpVerified
                ? TextConstants.enterNewPasswordTitle
                : TextConstants.enterOtpTitle,
            fontSize: size.width * 0.06,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.01),
          if (!isOtpVerified)
            OtpStep(
              phoneNumber: phoneNumber,
              isVerifying: isVerifying,
              otpController: otpController,
              otpFocusNode: otpFocusNode,
              size: size,
            )
          else
            Column(
              children: [
                if (errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.03),
                    margin: EdgeInsets.only(bottom: size.height * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: size.width * 0.05,
                        ),
                        SizedBox(width: size.width * 0.02),
                        Expanded(
                          child: TextComponent(
                            labelText: errorMessage!,
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                NewPasswordStep(
                  isResetting: isResetting,
                  newPasswordController: newPasswordController,
                  obscureNewPassword: obscureNewPassword,
                  onToggleObscure: onToggleObscure,
                  size: size,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
