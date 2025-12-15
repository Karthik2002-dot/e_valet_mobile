import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/login_api_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/phone_password_login_request.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitial()) {
    on<LoginIdChanged>(_onLoginIdChanged);
    on<PinChanged>(_onPinChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  String _loginId = '';
  String _pin = '';

  void _onLoginIdChanged(
    LoginIdChanged event,
    Emitter<LoginState> emit,
  ) {
    _loginId = event.loginId.trim();
  }

  void _onPinChanged(
    PinChanged event,
    Emitter<LoginState> emit,
  ) {
    _pin = event.pin;
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    // Validate inputs
    if (_loginId.isEmpty) {
      emit(const LoginFailure('Please enter your Phone Number'));
      return;
    }

    if (_pin.isEmpty) {
      emit(const LoginFailure('Please enter your Password'));
      return;
    }

    try {
      final request = PhonePasswordLoginRequest(
        phoneNumber: _loginId,
        password: _pin,
      );

      final success = await LoginApiService.verifyPhonePasswordLogin(request);

      if (success) {
        emit(const LoginSuccess());
      } else {
        emit(const LoginFailure('Invalid phone number or password'));
      }
    } on ApiException catch (e) {
      emit(LoginFailure(e.message));
    } catch (_) {
      emit(const LoginFailure('Something went wrong. Please try again.'));
    }
  }

  void _onLoginReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(const LoginInitial());
  }
}
