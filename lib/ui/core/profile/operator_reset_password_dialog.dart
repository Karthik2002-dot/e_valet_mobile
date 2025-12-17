import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/change_password/change_password_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/change_password/change_password_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/change_password/change_password_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/elevated_button.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/password_text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_button.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class OperatorResetPasswordDialog extends StatefulWidget {
  const OperatorResetPasswordDialog({super.key});

  @override
  State<OperatorResetPasswordDialog> createState() =>
      _OperatorResetPasswordDialogState();
}

class _OperatorResetPasswordDialogState
    extends State<OperatorResetPasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleUpdate(BuildContext context) {
    context.read<ChangePasswordBloc>().add(
          ChangePasswordSubmitted(
            oldPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordBloc(),
      child: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state.isSuccess) {
            SnackBars.showSuccessSnackBar(
              context,
              TextConstants.passwordChangedSuccess,
            );
            Navigator.of(context).pop();
          } else if (state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            SnackBars.showErrorSnackBar(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          final isLoading = state.isLoading;

          return Dialog(
            backgroundColor: AppColors.white,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.06,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextComponent(
                    labelText: TextConstants.resetPassword,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  PasswordTextField(
                    controller: _currentPasswordController,
                    labelText: TextConstants.currentPasswordLabel,
                    hintText: TextConstants.currentPasswordHint,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  PasswordTextField(
                    controller: _newPasswordController,
                    labelText: TextConstants.newPasswordLabel,
                    hintText: TextConstants.newPasswordHint,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    labelText: TextConstants.confirmNewPasswordLabel,
                    hintText: TextConstants.confirmNewPasswordHint,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButtonComponent(
                        labelText: TextConstants.close,
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontColor: AppColors.grey,
                        fontWeight: FontWeight.w500,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      ElevatedButtonComponent(
                        labelText: TextConstants.update,
                        onPressed:
                            isLoading ? () {} : () => _handleUpdate(context),
                        elevatedButtonBackgroundColor: AppColors.accent,
                        radius: 8,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontColor: AppColors.white,
                        fontWeight: FontWeight.w600,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
                        icon: isLoading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
