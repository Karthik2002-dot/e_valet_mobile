import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_event.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/password_text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/elevated_button.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_button.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/phone_number_field.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/oauth/forgot_password/forgot_password_screen.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController loginIdController;
  final TextEditingController pinController;
  final FocusNode loginIdFocusNode;
  final FocusNode pinFocusNode;

  const LoginForm({
    super.key,
    required this.loginIdController,
    required this.pinController,
    required this.loginIdFocusNode,
    required this.pinFocusNode,
  });

  void _handleLogin(BuildContext context) {
    context.read<LoginBloc>().add(const LoginSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // White card with blue border
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 1,
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.05,
              ),
              border: Border.all(
                color: AppColors.primary, // Blue border
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Purple person icon
                Icon(
                  Icons.person_outline,
                  color: AppColors.black,
                  size: MediaQuery.of(context).size.width * 0.2,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                // Login prompt
                TextComponent(
                  labelText: TextConstants.loginPrompt,
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                // Phone number with country code
                PhoneNumberField(
                  labelText: TextConstants.phoneNumberLabel,
                  hintText: TextConstants.phoneNumberHint,
                  controller: loginIdController,
                  focusNode: loginIdFocusNode,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(pinFocusNode);
                  },
                  onChanged: (value) =>
                      context.read<LoginBloc>().add(LoginIdChanged(value)),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                // Password field
                PasswordTextField(
                  controller: pinController,
                  focusNode: pinFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(context),
                  labelText: TextConstants.passwordLabel,
                  hintText: TextConstants.passwordHint,
                  onChanged: (value) =>
                      context.read<LoginBloc>().add(PinChanged(value)),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                // Login button
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    final isLoading = state is LoginLoading;
                    void handlePress() {
                      if (!isLoading) {
                        _handleLogin(context);
                      }
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButtonComponent(
                        labelText: isLoading
                            ? TextConstants.loginButtonLoading
                            : TextConstants.loginButton,
                        onPressed: handlePress,
                        elevatedButtonBackgroundColor:
                            AppColors.accent, // Orange
                        radius: 8,
                        fontSize: 16,
                        fontColor: AppColors.white,
                        fontWeight: FontWeight.w600,
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        icon: isLoading
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward,
                                color: AppColors.white,
                                size: MediaQuery.of(context).size.width * 0.05,
                              ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                // Forgot Password link
                Row(
                  children: [
                    Spacer(),
                    TextButtonComponent(
                      labelText: TextConstants.forgotPassword,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      fontSize: 14,
                      fontColor: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
