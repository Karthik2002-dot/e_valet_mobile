import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/forgot_password/forgot_password_event.dart';
import 'package:niloufer_valet_mobile/bloc/forgot_password/forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(const ForgotPasswordInitial()) {
    on<ForgotPasswordPhoneChanged>(_onPhoneChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
    on<ForgotPasswordReset>(_onReset);
  }

  String _phoneNumber = '';

  void _onPhoneChanged(
    ForgotPasswordPhoneChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    _phoneNumber = event.phoneNumber.trim();
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());

    // Validate phone number
    if (_phoneNumber.isEmpty) {
      emit(const ForgotPasswordFailure('Please enter your phone number'));
      return;
    }

    // TODO: Call forgot password API service when available
    // For now, simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Simulate success
    emit(const ForgotPasswordSuccess(
      'Password reset instructions have been sent to your phone number.',
    ));
  }

  void _onReset(
    ForgotPasswordReset event,
    Emitter<ForgotPasswordState> emit,
  ) {
    _phoneNumber = '';
    emit(const ForgotPasswordInitial());
  }
}
