import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/api/driver/driver_status_api_service.dart';
import 'package:niloufer_valet_mobile/api/oauth/profile_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/services/oauth/session_manager.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/services/websocket/websocket_helper.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final WebSocketBloc? webSocketBloc;

  SplashBloc({this.webSocketBloc}) : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashAnimationCompleted>(_onSplashAnimationCompleted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    // Simulate loading time or any initialization
    await Future.delayed(const Duration(milliseconds: 500));

    emit(const SplashLoaded());
  }

  Future<void> _onSplashAnimationCompleted(
    SplashAnimationCompleted event,
    Emitter<SplashState> emit,
  ) async {
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

      // Get outletId if user is an operator
      final isOperator = roles.any((r) => r.contains('operator'));
      final isDriver = roles.any((r) => r.contains('driver'));
      if (isOperator) {
        outletId = dotenv.env['OUTLET_ID'] ?? '1';
      }

      // Driver: getDriverStatus is the gate when opening the app — offline → login, online → home.
      if (isDriver) {
        try {
          final driverStatus = await DriverStatusApiService.getDriverStatus();
          if (driverStatus.isOffline) {
            await TokenStorage.clearAll();
            await SessionManager.clearSessionFlags();
            emit(const SplashCompleted(isAuthenticated: false, roles: []));
            return;
          }
          // Online (or ON_BREAK): continue to driver home
        } catch (e) {
          // Status fetch failed (e.g. network): allow navigation to driver home so they can retry there
          print('Splash: Driver status fetch failed: $e');
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
}
