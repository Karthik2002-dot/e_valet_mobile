import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/api/driver/driver_status_api_service.dart';
import 'package:niloufer_valet_mobile/api/oauth/login_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/status/clock_in_request.dart';
import 'package:niloufer_valet_mobile/models/oauth/phone_password_login_request.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/notification/firebase_messaging_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
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
        final roles = profile.roles.map((r) => r.toLowerCase()).toList();
        final userId = profile.user.id;
        final isOperator = roles.any((r) => r.contains('operator'));
        final isDriver = roles.any((r) => r.contains('driver'));

        try {
          if (webSocketBloc != null) {
            String? outletId;
            if (isOperator) {
              outletId = dotenv.env['OUTLET_ID'] ?? '1';
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

        // Automatically clock in (go online) for drivers after successful login
        // Await so clock-in completes before navigate; driver home then shows ONLINE
        if (isDriver) {
          final clockInError = await _clockInAfterLogin();
          if (clockInError != null && _isClockInTooFarError(clockInError)) {
            emit(LoginSuccessClockInTooFar(
              profile: profile,
              message: clockInError,
            ));
            return;
          }
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

  /// Returns error message if clock-in failed, null if success.
  /// Caller uses this to show "too far" screen when appropriate.
  Future<String?> _clockInAfterLogin() async {
    try {
      log('Starting automatic clock-in after login...');

      // Get location - try stored location first, then current location
      double latitude;
      double longitude;
      double accuracy;

      try {
        var locationData = await TokenStorage.getCurrentLocation();
        if (locationData != null) {
          latitude = locationData['latitude'] as double;
          longitude = locationData['longitude'] as double;
          accuracy = locationData['accuracy'] as double? ?? 0.0;
          log('Using stored location for clock-in');
        } else {
          // Fallback: Get current location if stored location not available
          final coordinates = await LocationService.getCurrentCoordinates();
          latitude = coordinates['latitude']!;
          longitude = coordinates['longitude']!;
          accuracy = coordinates['accuracy']!;

          // Save for future use
          final location =
              '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
          await TokenStorage.saveCurrentLocation(
            latitude: latitude,
            longitude: longitude,
            location: location,
          );
          log('Using current location for clock-in');
        }
      } catch (e) {
        log('Failed to get location for clock-in: $e');
        // If location fails, use default values (0, 0) - API might handle this
        latitude = 0.0;
        longitude = 0.0;
        accuracy = 0.0;
        log('Using default location (0, 0) for clock-in');
      }

      // Call clock-in API
      final clockInRequest = ClockInRequest(
        outletId: int.tryParse(dotenv.env['OUTLET_ID'] ?? '1') ?? 1,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );

      await DriverStatusApiService.clockIn(clockInRequest);
      log('Automatic clock-in successful after login');
      return null;
    } on ApiException catch (e) {
      log('Failed to clock in automatically after login: ${e.message}');
      return e.message;
    } catch (e) {
      log('Failed to clock in automatically after login: $e');
      return null; // Other errors: continue to driver home as offline
    }
  }

  /// True if the clock-in error indicates driver is too far from outlet.
  bool _isClockInTooFarError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('too far') ||
        (lower.contains('distance') && lower.contains('allowed'));
  }
}
