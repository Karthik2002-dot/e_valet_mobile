import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/password_reset_otp/password_reset_otp_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/password_reset_otp/password_reset_otp_event.dart';
import 'package:niloufer_valet_mobile/bloc/password_reset_otp/password_reset_otp_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/elevated_button.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/otp_input.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class PasswordResetOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const PasswordResetOtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PasswordResetOtpScreen> createState() => _PasswordResetOtpScreenState();
}

class _PasswordResetOtpScreenState extends State<PasswordResetOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _obscureNewPassword = true;

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordResetOtpBloc()
        ..add(PasswordResetOtpInitialized(widget.phoneNumber)),
      child: BlocListener<PasswordResetOtpBloc, PasswordResetOtpState>(
        listener: (context, state) {
          if (state is PasswordResetOtpVerified) {
            SnackBars.showSuccessSnackBar(context, state.message);
          } else if (state is PasswordResetOtpResetSuccess) {
            SnackBars.showSuccessSnackBar(context, state.message);
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is PasswordResetOtpFailure) {
            SnackBars.showErrorSnackBar(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: const CustomAppBar(),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: BlocBuilder<PasswordResetOtpBloc,
                          PasswordResetOtpState>(
                        builder: (context, state) {
                          final storedPhone = state is PasswordResetOtpInitial
                              ? state.storedPhone
                              : null;
                          final phoneNumber = storedPhone ?? widget.phoneNumber;
                          final isOtpVerified =
                              state is PasswordResetOtpVerified;
                          final isVerifying =
                              state is PasswordResetOtpVerifying;
                          final isResetting =
                              state is PasswordResetOtpResetting;

                          return Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 1,
                            ),
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.05,
                              ),
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
                                  size:
                                      MediaQuery.of(context).size.width * 0.2,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                TextComponent(
                                  labelText: TextConstants.enterOtpTitle,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.06,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                if (!isOtpVerified) ...[
                                  TextComponent(
                                    labelText:
                                        TextConstants.otpSentTo(phoneNumber),
                                    fontSize:
                                        MediaQuery.of(context).size.width * 0.04,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grey,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
                                  OtpInput(
                                    length: 6,
                                    controller: _otpController,
                                    focusNode: _otpFocusNode,
                                    autoFocus: true,
                                    onChanged: (value) {
                                      context.read<PasswordResetOtpBloc>().add(
                                            PasswordResetOtpChanged(value),
                                          );
                                    },
                                    onCompleted: (value) {
                                      context.read<PasswordResetOtpBloc>().add(
                                            PasswordResetOtpChanged(value),
                                          );
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
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
                                      elevatedButtonBackgroundColor:
                                          AppColors.accent,
                                      radius: 8,
                                      fontSize: 16,
                                      fontColor: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                      padding: EdgeInsets.symmetric(
                                        vertical: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.02,
                                      ),
                                      icon: Icon(
                                        Icons.verified_user_outlined,
                                        color: AppColors.white,
                                        size: MediaQuery.of(context).size.width *
                                            0.05,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  TextComponent(
                                    labelText:
                                        TextConstants.otpVerifiedSetPassword,
                                    fontSize:
                                        MediaQuery.of(context).size.width * 0.04,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  TextField(
                                    controller: _newPasswordController,
                                    obscureText: _obscureNewPassword,
                                    onChanged: (value) {
                                      context.read<PasswordResetOtpBloc>().add(
                                            PasswordResetOtpNewPasswordChanged(
                                                value),
                                          );
                                    },
                                    decoration: InputDecoration(
                                      labelText: TextConstants.newPasswordLabel,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureNewPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureNewPassword =
                                                !_obscureNewPassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButtonComponent(
                                      labelText: isResetting
                                          ? TextConstants.submittingNewPassword
                                          : TextConstants.submitNewPassword,
                                      onPressed: () {
                                        if (!isResetting) {
                                          context
                                              .read<PasswordResetOtpBloc>()
                                              .add(const PasswordResetOtpResetPasswordSubmitted());
                                        }
                                      },
                                      elevatedButtonBackgroundColor:
                                          AppColors.accent,
                                      radius: 8,
                                      fontSize: 16,
                                      fontColor: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                      padding: EdgeInsets.symmetric(
                                        vertical: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.02,
                                      ),
                                      icon: Icon(
                                        Icons.lock_reset,
                                        color: AppColors.white,
                                        size: MediaQuery.of(context).size.width *
                                            0.05,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
