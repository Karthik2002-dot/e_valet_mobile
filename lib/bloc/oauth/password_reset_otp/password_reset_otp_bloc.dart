import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/reset_password_api_service.dart';
import 'package:niloufer_valet_mobile/api/oauth/verify_reset_otp_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/password_reset_otp/password_reset_otp_event.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/password_reset_otp/password_reset_otp_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/reset_password_request.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class PasswordResetOtpBloc
    extends Bloc<PasswordResetOtpEvent, PasswordResetOtpState> {
  PasswordResetOtpBloc() : super(const PasswordResetOtpInitial()) {
    on<PasswordResetOtpInitialized>(_onInitialized);
    on<PasswordResetOtpChanged>(_onOtpChanged);
    on<PasswordResetOtpVerifySubmitted>(_onVerifySubmitted);
    on<PasswordResetOtpNewPasswordChanged>(_onNewPasswordChanged);
    on<PasswordResetOtpResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  String _phoneNumber = '';
  String _otp = '';
  String _newPassword = '';
  String? _resetToken;

  Future<void> _onInitialized(
    PasswordResetOtpInitialized event,
    Emitter<PasswordResetOtpState> emit,
  ) async {
    _phoneNumber = event.phoneNumber;
    final saved = await TokenStorage.getPhoneNumber();
    emit(PasswordResetOtpInitial(storedPhone: saved));
  }

  void _onOtpChanged(
    PasswordResetOtpChanged event,
    Emitter<PasswordResetOtpState> emit,
  ) {
    _otp = event.otp.trim();
  }

  Future<void> _onVerifySubmitted(
    PasswordResetOtpVerifySubmitted event,
    Emitter<PasswordResetOtpState> emit,
  ) async {
    // Validate OTP
    if (_otp.length != 6) {
      emit(const PasswordResetOtpFailure(TextConstants.enterSixDigitOtp));
      return;
    }

    emit(const PasswordResetOtpVerifying());

    try {
      final identifier = await TokenStorage.getPhoneNumber() ?? _phoneNumber;
      final message = await VerifyResetOtpApiService.verifyPasswordResetOtp(
        identifier: identifier,
        otp: _otp,
      );

      _resetToken = message.resetToken ?? await TokenStorage.getResetToken();

      if (_resetToken == null || _resetToken!.isEmpty) {
        emit(const PasswordResetOtpFailure(TextConstants.resetTokenMissing));
        return;
      }

      emit(PasswordResetOtpVerified(
        message: message.message,
        resetToken: _resetToken,
      ));
    } on ApiException catch (e) {
      emit(PasswordResetOtpFailure(e.message));
    } catch (_) {
      emit(const PasswordResetOtpFailure(TextConstants.genericError));
    }
  }

  void _onNewPasswordChanged(
    PasswordResetOtpNewPasswordChanged event,
    Emitter<PasswordResetOtpState> emit,
  ) {
    _newPassword = event.password.trim();
  }

  Future<void> _onResetPasswordSubmitted(
    PasswordResetOtpResetPasswordSubmitted event,
    Emitter<PasswordResetOtpState> emit,
  ) async {
    // Validate password
    if (_newPassword.isEmpty) {
      emit(const PasswordResetOtpFailure(TextConstants.newPasswordRequired));
      return;
    }

    final token = _resetToken ?? await TokenStorage.getResetToken();
    if (token == null || token.isEmpty) {
      emit(const PasswordResetOtpFailure(TextConstants.resetTokenMissing));
      return;
    }

    emit(PasswordResetOtpResetting(resetToken: token));

    try {
      final message = await ResetPasswordApiService.resetPassword(
        ResetPasswordRequest(
          resetToken: token,
          newPassword: _newPassword,
        ),
      );

      emit(PasswordResetOtpResetSuccess(message));
    } on ApiException catch (e) {
      // Preserve the verified state when password reset fails
      // This allows the user to stay on the new password step and see the error
      emit(PasswordResetOtpVerifiedWithError(
        message: 'OTP verified',
        errorMessage: e.message,
        resetToken: token,
      ));
    } catch (_) {
      // Preserve the verified state when password reset fails
      final token = _resetToken ?? await TokenStorage.getResetToken();
      emit(PasswordResetOtpVerifiedWithError(
        message: 'OTP verified',
        errorMessage: TextConstants.genericError,
        resetToken: token,
      ));
    }
  }
}
