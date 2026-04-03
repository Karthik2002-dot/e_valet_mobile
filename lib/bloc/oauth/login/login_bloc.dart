import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/api/driver/driver_status_api_service.dart';
import 'package:niloufer_valet_mobile/api/oauth/login_api_service.dart';
import 'package:niloufer_valet_mobile/api/outlet/outlet_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/status/clock_in_request.dart';
import 'package:niloufer_valet_mobile/models/oauth/phone_password_login_request.dart';
import 'package:niloufer_valet_mobile/models/oauth/profile.dart';
import 'package:niloufer_valet_mobile/models/outlet/verify_location_request.dart';
import 'package:niloufer_valet_mobile/models/outlet/verify_location_response.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/notification/firebase_messaging_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/services/websocket/websocket_helper.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
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
    on<OutletSelected>(_onOutletSelected);
    on<LoginReset>(_onLoginReset);
  }

  String _loginId = '';
  String _pin = '';

  // Preserved across the outlet selection step
  Profile? _pendingProfile;
  bool _pendingIsDriver = false;
  bool _pendingIsOperator = false;
  bool _pendingIsScanner = false;

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

    if (_loginId.isEmpty) {
      emit(LoginFailure(TextConstants.validationPhoneRequired));
      return;
    }

    if (_pin.isEmpty) {
      emit(LoginFailure(TextConstants.validationPasswordRequired));
      return;
    }

    try {
      final request = PhonePasswordLoginRequest(
        phoneNumber: _loginId,
        password: _pin,
      );

      final profile = await LoginApiService.verifyPhonePasswordLogin(request);

      if (profile.roles.isEmpty) {
        emit(
          const LoginFailure(
            'No roles are assigned to your account. Please contact your administrator to request access.',
          ),
        );
        return;
      }

      // Register FCM token after successful login
      try {
        await firebaseMessagingService?.registerFcmTokenAfterLogin();
        log('FCM token registration initiated after login');
      } catch (e) {
        log('Failed to register FCM token after login: $e');
      }

      final roles = profile.roles.map((r) => r.toLowerCase()).toList();
      _pendingProfile = profile;
      _pendingIsDriver = roles.any((r) => r.contains('driver'));
      _pendingIsOperator = roles.any((r) => r.contains('operator'));
      _pendingIsScanner = roles.any((r) => r.contains('scanner'));

      // Fetch outlets so the user can pick one before clock-in / verify-location
      final outlets = await OutletApiService.getOutlets();

      emit(LoginSuccessNeedsOutletSelection(
        profile: profile,
        outlets: outlets,
        isDriver: _pendingIsDriver,
        isOperator: _pendingIsOperator,
        isScanner: _pendingIsScanner,
      ));
    } on ApiException catch (e) {
      emit(LoginFailure(e.message));
    } catch (_) {
      emit(
        const LoginFailure('Something went wrong. Please try again.'),
      );
    }
  }

  Future<void> _onOutletSelected(
    OutletSelected event,
    Emitter<LoginState> emit,
  ) async {
    final profile = _pendingProfile;
    if (profile == null) return;

    emit(const LoginOutletSelectionLoading());

    final outlet = event.outlet;

    try {
      // Persist selected outlet to Hive and update dotenv in-memory so
      // ApiConfig.outletId and authorizedHeaders reflect the choice immediately.
      await TokenStorage.saveSelectedOutlet(
        outletId: outlet.id,
        outletName: outlet.name,
      );
      dotenv.env['OUTLET_ID'] = outlet.id.toString();

      // Get the user's current location (shared by both driver and operator/scanner paths)
      double latitude;
      double longitude;
      double accuracy;

      try {
        final locationData = await TokenStorage.getCurrentLocation();
        if (locationData != null) {
          latitude = locationData['latitude'] as double;
          longitude = locationData['longitude'] as double;
          accuracy = locationData['accuracy'] as double? ?? 0.0;
        } else {
          final coordinates = await LocationService.getCurrentCoordinates();
          latitude = coordinates['latitude']!;
          longitude = coordinates['longitude']!;
          accuracy = coordinates['accuracy']!;

          final location =
              '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
          await TokenStorage.saveCurrentLocation(
            latitude: latitude,
            longitude: longitude,
            location: location,
          );
        }
      } catch (e) {
        log('Failed to get location after outlet selection: $e');
        latitude = 0.0;
        longitude = 0.0;
        accuracy = 0.0;
      }

      // Connect WebSocket with the chosen outlet
      final userId = profile.user.id;
      try {
        if (webSocketBloc != null) {
          String? outletId;
          if (_pendingIsOperator || _pendingIsScanner) {
            outletId = outlet.id.toString();
          }
          await WebSocketHelper.connectAfterLogin(
            webSocketBloc: webSocketBloc!,
            outletId: outletId,
            operatorId: _pendingIsOperator ? userId : null,
            driverId: _pendingIsDriver ? userId : null,
            initialDelay: const Duration(milliseconds: 500),
          );
          log('WebSocket connection initiated after outlet selection');
        }
      } catch (e) {
        log('Failed to connect WebSocket after outlet selection: $e');
      }

      if (_pendingIsDriver) {
        // Driver: clock-in API enforces location check server-side
        final clockInError = await _clockInAfterLogin(
          outletId: outlet.id,
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
        );
        if (clockInError != null && _isLocationTooFarMessage(clockInError)) {
          emit(LoginSuccessClockInTooFar(
            profile: profile,
            message: clockInError,
          ));
          return;
        }
      } else {
        // Operator / Scanner: verify location via dedicated endpoint
        final verifyRequest = VerifyLocationRequest(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
        );
        late final VerifyLocationResponse verifyResponse;
        try {
          verifyResponse = await OutletApiService.verifyLocation(
            outlet.id,
            verifyRequest,
          );
        } on ApiException catch (e) {
          // Backend may return 4xx with a message instead of 200 + withinBounds: false.
          if (_isLocationTooFarMessage(e.message)) {
            emit(LoginSuccessLocationTooFar(
              profile: profile,
              outletName: outlet.name,
              distanceMeters: 0,
              allowedRadiusMeters: 0,
              detailMessage: e.message,
            ));
            return;
          }
          rethrow;
        }

        if (!verifyResponse.withinBounds) {
          emit(LoginSuccessLocationTooFar(
            profile: profile,
            outletName: verifyResponse.outletName,
            distanceMeters: verifyResponse.distanceMeters,
            allowedRadiusMeters: verifyResponse.allowedRadiusMeters,
          ));
          return;
        }
      }

      emit(LoginSuccess(profile));
    } on ApiException catch (e) {
      emit(LoginFailure(e.message));
    } catch (_) {
      emit(
        const LoginFailure('Something went wrong. Please try again.'),
      );
    }
  }

  void _onLoginReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    _pendingProfile = null;
    _pendingIsDriver = false;
    _pendingIsOperator = false;
    _pendingIsScanner = false;
    emit(const LoginInitial());
  }

  /// Returns error message if clock-in failed, null if succeeded.
  Future<String?> _clockInAfterLogin({
    required int outletId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    try {
      log('Starting automatic clock-in after outlet selection...');
      final clockInRequest = ClockInRequest(
        outletId: outletId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );
      await DriverStatusApiService.clockIn(clockInRequest);
      log('Automatic clock-in successful after outlet selection');
      return null;
    } on ApiException catch (e) {
      log('Failed to clock in after outlet selection: ${e.message}');
      return e.message;
    } catch (e) {
      log('Failed to clock in after outlet selection: $e');
      return null;
    }
  }

  bool _isLocationTooFarMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('too far') ||
        (lower.contains('distance') && lower.contains('allowed'));
  }
}
