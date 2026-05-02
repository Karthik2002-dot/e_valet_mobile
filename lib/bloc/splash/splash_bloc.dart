import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/api/driver/driver_status_api_service.dart';
import 'package:niloufer_valet_mobile/api/oauth/profile_api_service.dart';
import 'package:niloufer_valet_mobile/api/outlet/outlet_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/outlet/verify_location_request.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/session_manager.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/services/translations/translations_cache.dart';
import 'package:niloufer_valet_mobile/services/websocket/websocket_helper.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final WebSocketBloc? webSocketBloc;
  final AppTranslationsNotifier appTranslationsNotifier;

  SplashBloc({this.webSocketBloc, required this.appTranslationsNotifier})
      : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashAnimationCompleted>(_onSplashAnimationCompleted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    // Ensure translations are loaded/refreshed for current language (on open or install)
    try {
      await TranslationsCache().ensureTranslationsLoaded();
      // Reload in-memory translations so login screen and other UI show translated strings
      await appTranslationsNotifier.load();
    } catch (e, st) {
      // Log translation loading failures instead of silently swallowing them
      print('SplashBloc: Failed to ensure translations are loaded: $e');
      print(st);
    }

    // Simulate loading time or any initialization
    await Future.delayed(const Duration(milliseconds: 500));

    emit(const SplashLoaded());
  }

  Future<void> _onSplashAnimationCompleted(
    SplashAnimationCompleted event,
    Emitter<SplashState> emit,
  ) async {
    // Enforce 3:00 AM daily reset before any auto-login path.
    await SessionManager.enforceDailyResetIfNeeded();

    // Check if user is already logged in
    final isAuthenticated = await SessionManager.isUserLoggedIn();

    if (!isAuthenticated) {
      emit(const SplashCompleted(isAuthenticated: false, roles: []));
      return;
    }

    // If authenticated, try to fetch the profile to determine roles.
    List<String> roles = [];
    String? outletId;
    String? userId;

    try {
      final profile = await ProfileApiService.getProfile();
      roles = profile.normalizedRoles;
      userId = profile.user.id;

      // Get outletId if user is operator or scanner (both need outlet room for real-time updates)
      final isOperator = roles.any((r) => r.contains('operator'));
      final isScanner = roles.any((r) => r.contains('scanner'));
      final isAdmin = roles.any((r) => r.contains('admin'));
      final isDriver = roles.any((r) => r.contains('driver'));
      if (isOperator || isScanner) {
        outletId = dotenv.env['OUTLET_ID'] ?? '1';
      }

      // If user is a driver, check status before WebSocket: OFFLINE means session ended → log out and go to login.
      // Only connect WebSocket when driver is ONLINE (or operator).
      if (isDriver) {
        try {
          final driverStatus = await DriverStatusApiService.getDriverStatus();
          if (driverStatus.isOffline) {
            await TokenStorage.clearAll();
            await SessionManager.clearSessionFlags();
            emit(const SplashCompleted(isAuthenticated: false, roles: []));
            return;
          }
        } catch (e) {
          // If status fetch fails (e.g. network), still allow navigation to driver home
          print('Splash: Driver status fetch failed: $e');
        }
      }

      // Operator / scanner / admin (same outlet verify as after login): if too far, clear session — mirrors driver OFFLINE gate so refresh cannot open the dashboard.
      final needsOutletLocationVerify =
          !isDriver && (isOperator || isScanner || isAdmin);
      if (needsOutletLocationVerify) {
        final tooFar = await _isTooFarForStoredOutlet();
        if (tooFar) {
          await TokenStorage.clearAll();
          await SessionManager.clearSessionFlags();
          emit(const SplashCompleted(isAuthenticated: false, roles: []));
          return;
        }
      }

      // Initialize WebSocket only when user is allowed to continue (operator, or driver with ONLINE status)
      if (webSocketBloc != null) {
        await WebSocketHelper.connectAfterLogin(
          webSocketBloc: webSocketBloc!,
          outletId: outletId,
          operatorId: isOperator ? userId : null,
          driverId: isDriver ? userId : null,
          initialDelay:
              const Duration(milliseconds: 1500), // Longer delay for splash
        );
      }
    } catch (e) {
      // Ignore profile fetch failure; fallback to empty roles
      print('Splash: Profile fetch failed: $e');
      emit(const SplashCompleted(isAuthenticated: false, roles: []));
      return;
    }

    emit(SplashCompleted(isAuthenticated: isAuthenticated, roles: roles));
  }

  /// Same location check as [LoginBloc] after outlet selection. Returns true if user must not enter the app.
  Future<bool> _isTooFarForStoredOutlet() async {
    var outletId = await TokenStorage.getSelectedOutletId();
    outletId ??= int.tryParse(dotenv.env['OUTLET_ID'] ?? '');
    if (outletId == null) {
      return false;
    }

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
      }
    } catch (e) {
      print('Splash: Failed to get location for verify-location: $e');
      latitude = 0.0;
      longitude = 0.0;
      accuracy = 0.0;
    }

    try {
      final response = await OutletApiService.verifyLocation(
        outletId,
        VerifyLocationRequest(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
        ),
      );
      return !response.withinBounds;
    } on ApiException catch (e) {
      if (_isLocationTooFarMessage(e.message)) return true;
      print('Splash: verify-location ApiException: ${e.message}');
      return false;
    } catch (e) {
      print('Splash: verify-location failed: $e');
      return false;
    }
  }

  bool _isLocationTooFarMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('too far') ||
        (lower.contains('distance') && lower.contains('allowed'));
  }
}
