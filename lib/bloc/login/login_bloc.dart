import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    // Validate inputs
    if (event.loginId.isEmpty) {
      emit(const LoginFailure('Please enter your Login ID'));
      return;
    }

    if (event.pin.isEmpty) {
      emit(const LoginFailure('Please enter your PIN'));
      return;
    }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Replace with actual API call
    // For now, simulate success
    if (event.loginId.isNotEmpty && event.pin.isNotEmpty) {
      emit(const LoginSuccess());
    } else {
      emit(const LoginFailure('Invalid Login ID or PIN'));
    }
  }

  void _onLoginReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(const LoginInitial());
  }
}
