import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/services/oauth/session_manager.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/api/oauth/profile_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
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
      userId = profile.user?.id;

      // Get outletId if user is an operator
      final isOperator = roles.any((r) => r.contains('operator'));
      if (isOperator) {
        outletId = '2';
      }

      // Initialize WebSocket connection if user is authenticated
      if (webSocketBloc != null && userId != null) {
        await WebSocketHelper.connectAfterLogin(
          webSocketBloc: webSocketBloc!,
          outletId: outletId,
          operatorId: isOperator ? userId : null,
          driverId: roles.any((r) => r.contains('driver')) ? userId : null,
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
