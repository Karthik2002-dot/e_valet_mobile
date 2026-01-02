import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niloufer_valet_mobile/services/oauth/session_manager.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashAnimationCompleted>(_onSplashAnimationCompleted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    // Request location permission and get location
    try {
      // Check and request location permission
      LocationPermission permission = await LocationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await LocationService.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Continue without location for now, will request when needed
      } else {
        // Get current location and store it
        try {
          final position = await LocationService.getCurrentLocation();
          final latitude = position.latitude;
          final longitude = position.longitude;
          final location =
              '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

          // Store location for use in accept, arrived, and handover APIs
          await TokenStorage.saveCurrentLocation(
            latitude: latitude,
            longitude: longitude,
            location: location,
          );
        } catch (e) {
          // Continue without location, will request when needed
        }
      }
    } catch (e) {
      // Continue without location, will request when needed
    }

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
    emit(SplashCompleted(isAuthenticated: isAuthenticated));
  }
}
