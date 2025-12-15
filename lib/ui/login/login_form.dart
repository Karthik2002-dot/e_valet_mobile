import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/login/login_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/login/login_event.dart';
import 'package:niloufer_valet_mobile/bloc/login/login_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/password_text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/elevated_button.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';

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
    final loginId = loginIdController.text.trim();
    final pin = pinController.text;

    context.read<LoginBloc>().add(
          LoginSubmitted(
            loginId: loginId,
            pin: pin,
          ),
        );
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
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
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
                // "Please Login to Continue" text
                TextComponent(
                  labelText: 'Please Login to Continue',
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                // Login ID field
                TextFieldComponent(
                  labelText: 'Phone Number',
                  hintText: 'Enter Phone Number',
                  controller: loginIdController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone,
                    size: 18,
                    color: AppColors.black,
                  ),
                  focusNode: loginIdFocusNode,
                  borderRadius: 8,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                // Password field
                PasswordTextField(
                  controller: pinController,
                  focusNode: pinFocusNode,
                  labelText: 'Password',
                  hintText: 'Enter Your Password',
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
                        labelText: isLoading ? 'Logging in...' : 'Login',
                        onPressed: handlePress,
                        elevatedButtonBackgroundColor:
                            AppColors.accent, // Orange
                        radius: 8,
                        fontSize: 16,
                        fontColor: AppColors.white,
                        fontWeight: FontWeight.w600,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                color: AppColors.white,
                                size: 20,
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
