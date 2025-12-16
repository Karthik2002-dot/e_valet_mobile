import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/forgot_password/forgot_password_event.dart';
import 'package:niloufer_valet_mobile/bloc/forgot_password/forgot_password_state.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/elevated_button.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/phone_number_field.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    context.read<ForgotPasswordBloc>().add(const ForgotPasswordSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(),
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            SnackBars.showSuccessSnackBar(context, state.message);
            // Navigate back to login after showing success message
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          } else if (state is ForgotPasswordFailure) {
            SnackBars.showErrorSnackBar(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: const CustomAppBar(),
          body: SafeArea(
            child: Column(
              children: [
                // Main content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
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
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05,
                            ),
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
                                // Lock icon
                                Icon(
                                  Icons.lock_outline,
                                  color: AppColors.black,
                                  size: MediaQuery.of(context).size.width * 0.2,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                // "Forgot Password" text
                                TextComponent(
                                  labelText: 'Forgot Password',
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
                                // Description text
                                TextComponent(
                                  labelText:
                                      'Enter your phone number to receive password reset instructions',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                // Phone number field
                                PhoneNumberField(
                                  labelText: 'Phone Number',
                                  hintText: 'Enter Phone Number',
                                  controller: _phoneController,
                                  focusNode: _phoneFocusNode,
                                  onChanged: (value) => context
                                      .read<ForgotPasswordBloc>()
                                      .add(ForgotPasswordPhoneChanged(value)),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                // Submit button
                                BlocBuilder<ForgotPasswordBloc,
                                    ForgotPasswordState>(
                                  builder: (context, state) {
                                    final isLoading =
                                        state is ForgotPasswordLoading;
                                    void handlePress() {
                                      if (!isLoading) {
                                        _handleSubmit(context);
                                      }
                                    }

                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButtonComponent(
                                        labelText: isLoading
                                            ? 'Sending...'
                                            : 'Send Reset Instructions',
                                        onPressed: handlePress,
                                        elevatedButtonBackgroundColor:
                                            AppColors.accent, // Orange
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
                                        icon: isLoading
                                            ? SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    AppColors.white,
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                Icons.send,
                                                color: AppColors.white,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
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
                    ),
                  ),
                ),
                // Footer
                const Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
