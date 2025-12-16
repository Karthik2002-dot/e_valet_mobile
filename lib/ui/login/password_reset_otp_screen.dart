import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/api/oauth/otp_api_service.dart';
import 'package:niloufer_valet_mobile/api/oauth/reset_password_api_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/reset_password_request.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
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

  String _otp = '';
  String? _storedPhone;
  bool _isLoading = false;
  String? _resetToken;
  bool _otpVerified = false;
  bool _isResetting = false;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _loadPhoneFromStorage();
  }

  Future<void> _loadPhoneFromStorage() async {
    final saved = await TokenStorage.getPhoneNumber();
    if (!mounted) return;
    setState(() {
      _storedPhone = saved;
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  bool get _isOtpComplete => _otp.length == 6;

  String get _identifier => _storedPhone ?? widget.phoneNumber;

  Future<void> _handleSubmit() async {
    if (!_isOtpComplete) {
      SnackBars.showErrorSnackBar(
        context,
        TextConstants.enterSixDigitOtp,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await OtpApiService.verifyPasswordResetOtp(
        identifier: _identifier,
        otp: _otp,
      );
      if (!mounted) return;
      _resetToken = message.resetToken ?? await TokenStorage.getResetToken();
      SnackBars.showSuccessSnackBar(context, message.message);
      if (_resetToken == null || _resetToken!.isEmpty) {
        SnackBars.showErrorSnackBar(
          context,
          TextConstants.resetTokenMissing,
        );
        return;
      }
      setState(() {
        _otpVerified = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      SnackBars.showErrorSnackBar(context, e.message);
    } catch (_) {
      if (!mounted) return;
      SnackBars.showErrorSnackBar(
        context,
        TextConstants.genericError,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    final password = _newPasswordController.text.trim();

    if (password.isEmpty) {
      SnackBars.showErrorSnackBar(
        context,
        TextConstants.newPasswordRequired,
      );
      return;
    }

    final token = _resetToken ?? await TokenStorage.getResetToken();
    if (token == null || token.isEmpty) {
      SnackBars.showErrorSnackBar(
        context,
        TextConstants.resetTokenMissing,
      );
      return;
    }

    setState(() {
      _isResetting = true;
    });

    try {
      final message = await ResetPasswordApiService.resetPassword(
        ResetPasswordRequest(
          resetToken: token,
          newPassword: password,
        ),
      );

      if (!mounted) return;
      SnackBars.showSuccessSnackBar(context, message);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      if (!mounted) return;
      SnackBars.showErrorSnackBar(context, e.message);
    } catch (_) {
      if (!mounted) return;
      SnackBars.showErrorSnackBar(
        context,
        TextConstants.genericError,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
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
                          size: MediaQuery.of(context).size.width * 0.2,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        TextComponent(
                          labelText: TextConstants.enterOtpTitle,
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        if (!_otpVerified) ...[
                          TextComponent(
                            labelText:
                                TextConstants.otpSentTo(widget.phoneNumber),
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          OtpInput(
                            length: 6,
                            controller: _otpController,
                            focusNode: _otpFocusNode,
                            autoFocus: true,
                            onChanged: (value) {
                              setState(() {
                                _otp = value.trim();
                              });
                            },
                            onCompleted: (value) {
                              setState(() {
                                _otp = value.trim();
                              });
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButtonComponent(
                              labelText: _isLoading
                                  ? TextConstants.verifyingOtp
                                  : TextConstants.verifyOtp,
                              onPressed: () {
                                if (!_isLoading) {
                                  _handleSubmit();
                                }
                              },
                              elevatedButtonBackgroundColor: AppColors.accent,
                              radius: 8,
                              fontSize: 16,
                              fontColor: AppColors.white,
                              fontWeight: FontWeight.w600,
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              icon: Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.white,
                                size: MediaQuery.of(context).size.width * 0.05,
                              ),
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          TextComponent(
                            labelText: TextConstants.otpVerifiedSetPassword,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          TextField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
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
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButtonComponent(
                              labelText: _isResetting
                                  ? TextConstants.submittingNewPassword
                                  : TextConstants.submitNewPassword,
                              onPressed: () {
                                if (!_isResetting) {
                                  _handlePasswordReset();
                                }
                              },
                              elevatedButtonBackgroundColor: AppColors.accent,
                              radius: 8,
                              fontSize: 16,
                              fontColor: AppColors.white,
                              fontWeight: FontWeight.w600,
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              icon: Icon(
                                Icons.lock_reset,
                                color: AppColors.white,
                                size: MediaQuery.of(context).size.width * 0.05,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
