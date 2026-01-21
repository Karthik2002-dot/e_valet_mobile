import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/login_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/phone_password_login_request.dart';
import 'package:niloufer_valet_mobile/services/notification/firebase_messaging_service.dart';
import 'package:niloufer_valet_mobile/services/websocket/websocket_helper.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseMessagingService? firebaseMessagingService;
  final WebSocketBloc? webSocketBloc;

  LoginBloc({
    this.firebaseMessagingService,
    this.webSocketBloc,
  }) : super(const LoginInitial()) {
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

      final profile = await LoginApiService.verifyPhonePasswordLogin(request);

      if (profile.roles.isNotEmpty) {
        // Register FCM token after successful login
        try {
          await firebaseMessagingService?.registerFcmTokenAfterLogin();
          log('FCM token registration initiated after login');
        } catch (e) {
          log('Failed to register FCM token after login: $e');
          // Don't fail the login if FCM registration fails
        }

        // Connect WebSocket after successful login
        try {
          if (webSocketBloc != null) {
            final roles = profile.roles.map((r) => r.toLowerCase()).toList();
            final userId = profile.user?.id;
            final isOperator = roles.any((r) => r.contains('operator'));
            final isDriver = roles.any((r) => r.contains('driver'));

            String? outletId;
            if (isOperator) {
              outletId = '1';
            }

            await WebSocketHelper.connectAfterLogin(
              webSocketBloc: webSocketBloc!,
              outletId: outletId,
              operatorId: isOperator ? userId : null,
              driverId: isDriver ? userId : null,
              initialDelay:
                  const Duration(milliseconds: 500), // Shorter delay for login
            );
            log('WebSocket connection initiated after login');
          }
        } catch (e) {
          log('Failed to connect WebSocket after login: $e');
          // Don't fail the login if WebSocket connection fails
        }

        emit(LoginSuccess(profile));
      } else {
        emit(
          const LoginFailure(
            'No roles are assigned to your account. Please contact your administrator to request access.',
          ),
        );
      }
    } on ApiException catch (e) {
      emit(LoginFailure(e.message));
    } catch (_) {
      emit(
        const LoginFailure(
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void _onLoginReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(const LoginInitial());
  }
}
