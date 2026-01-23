import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/api/driver/driver_status_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/status/clock_in_request.dart';
import 'package:niloufer_valet_mobile/models/driver/status/clock_out_request.dart';
import 'package:niloufer_valet_mobile/models/driver/status/break_start_request.dart';
import 'package:niloufer_valet_mobile/models/driver/status/break_end_request.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class DriverStatusBloc extends Bloc<DriverStatusEvent, DriverStatusState> {
  DriverStatusBloc() : super(const DriverStatusInitial()) {
    on<DriverStatusStarted>(_onStarted);
    on<DriverStatusRefreshed>(_onRefreshed);
    on<DriverStatusUpdated>(_onUpdated);
    on<DriverBreakToggled>(_onBreakToggled);
  }

  Future<void> _onStarted(
    DriverStatusStarted event,
    Emitter<DriverStatusState> emit,
  ) async {
    emit(const DriverStatusLoading());

    try {
      final status = await DriverStatusApiService.getDriverStatus();
      emit(DriverStatusLoaded(status));
    } on ApiException catch (e) {
      emit(DriverStatusError(e.message));
    } catch (_) {
      emit(const DriverStatusError(
        'Failed to load driver status. Please try again.',
      ));
    }
  }

  Future<void> _onRefreshed(
    DriverStatusRefreshed event,
    Emitter<DriverStatusState> emit,
  ) async {
    // Don't show loading state on refresh to avoid UI flicker
    try {
      final status = await DriverStatusApiService.getDriverStatus();
      emit(DriverStatusLoaded(status));
    } on ApiException catch (e) {
      // On refresh error, keep the previous state if it exists
      if (state is DriverStatusLoaded) {
        emit(DriverStatusError(e.message));
      } else {
        emit(DriverStatusError(e.message));
      }
    } catch (_) {
      if (state is DriverStatusLoaded) {
        // Keep previous state on unknown error during refresh
        return;
      }
      emit(const DriverStatusError(
        'Failed to refresh driver status. Please try again.',
      ));
    }
  }

  Future<void> _onUpdated(
    DriverStatusUpdated event,
    Emitter<DriverStatusState> emit,
  ) async {
    // Preserve previous state in case of error
    final previousState = state is DriverStatusLoaded
        ? (state as DriverStatusLoaded).status
        : null;

    // Check if user is already in desired state - if so, just emit current state
    if (previousState != null) {
      final isCurrentlyOnline = previousState.isOnline;
      final wantsToGoOnline = event.status.toUpperCase() == 'ONLINE';

      if ((isCurrentlyOnline && wantsToGoOnline) ||
          (!isCurrentlyOnline && !wantsToGoOnline)) {
        // Already in desired state, just emit current state
        emit(DriverStatusLoaded(previousState));
        return;
      }
    }

    // Emit loading state to disable toggle during API call
    emit(const DriverStatusLoading());

    // Get stored location or fetch new one
    try {
      var locationData = await TokenStorage.getCurrentLocation();

      double latitude;
      double longitude;
      double accuracy;

      if (locationData != null) {
        latitude = locationData['latitude'] as double;
        longitude = locationData['longitude'] as double;
        accuracy = locationData['accuracy'] as double? ?? 0.0;
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
      }

      if (event.status.toUpperCase() == 'ONLINE') {
        // Clock in - go online
        final clockInRequest = ClockInRequest(
          outletId: int.tryParse(dotenv.env['OUTLET_ID'] ?? '1') ?? 1,
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
        );

        final clockInResponse =
            await DriverStatusApiService.clockIn(clockInRequest);

        // After clock in, refresh status from API to get latest state
        final updatedStatus = await DriverStatusApiService.getDriverStatus();

        // Emit success state with message from API, then update to loaded state
        emit(DriverStatusClockInSuccess(
          status: updatedStatus,
          message: clockInResponse.message,
        ));
        // Immediately emit loaded state so UI updates
        emit(DriverStatusLoaded(updatedStatus));
      } else {
        // Clock out - go offline
        final clockOutRequest = ClockOutRequest(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
        );

        final clockOutResponse =
            await DriverStatusApiService.clockOut(clockOutRequest);

        // After clock out, status becomes OFFLINE
        // Refresh status to get updated state
        final updatedStatus = await DriverStatusApiService.getDriverStatus();

        // Emit success state with message from API, then update to loaded state
        emit(DriverStatusClockOutSuccess(
          status: updatedStatus,
          message: clockOutResponse.message,
        ));
        // Immediately emit loaded state so UI updates
        emit(DriverStatusLoaded(updatedStatus));
      }
    } on ApiException catch (e) {
      // On error, revert to previous state if it exists, otherwise emit error
      if (previousState != null) {
        // Revert to previous loaded state so toggle doesn't change
        emit(DriverStatusError(e.message));
        // After showing error, revert to previous state
        emit(DriverStatusLoaded(previousState));
      } else {
        emit(DriverStatusError(e.message));
      }
    } catch (e) {
      // Handle location errors or other exceptions
      final errorMessage = e.toString();
      String errorMsg;
      if (errorMessage.contains('location') ||
          errorMessage.contains('permission') ||
          errorMessage.contains('Location')) {
        errorMsg = errorMessage.contains('denied')
            ? 'Location permission is required to update status. Please grant location permission in app settings.'
            : errorMessage.contains('disabled')
                ? 'Location services are disabled. Please enable location services.'
                : 'Failed to get location. Please try again.';
      } else {
        errorMsg =
            'Failed to ${event.status.toUpperCase() == "ONLINE" ? "clock in" : "clock out"}. Please try again.';
      }

      // On error, revert to previous state if it exists
      if (previousState != null) {
        emit(DriverStatusError(errorMsg));
        // After showing error, revert to previous state
        emit(DriverStatusLoaded(previousState));
      } else {
        emit(DriverStatusError(errorMsg));
      }
    }
  }

  Future<void> _onBreakToggled(
    DriverBreakToggled event,
    Emitter<DriverStatusState> emit,
  ) async {
    // Preserve previous state in case of error
    final previousState = state is DriverStatusLoaded
        ? (state as DriverStatusLoaded).status
        : null;

    // Emit loading state to disable toggle during API call
    emit(const DriverStatusLoading());

    // Get stored location or fetch new one
    try {
      var locationData = await TokenStorage.getCurrentLocation();

      double latitude;
      double longitude;
      double accuracy;

      if (locationData != null) {
        latitude = locationData['latitude'] as double;
        longitude = locationData['longitude'] as double;
        accuracy = locationData['accuracy'] as double? ?? 0.0;
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
      }

      if (event.isOnBreak) {
        // Start break
        final breakStartRequest = BreakStartRequest(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
        );

        final breakStartResponse =
            await DriverStatusApiService.startBreak(breakStartRequest);

        // After starting break, refresh status from API to get latest state
        final updatedStatus = await DriverStatusApiService.getDriverStatus();

        // Emit success state with message from API, then update to loaded state
        emit(DriverBreakStartSuccess(
          status: updatedStatus,
          message: breakStartResponse.message,
        ));
        // Immediately emit loaded state so UI updates
        emit(DriverStatusLoaded(updatedStatus));
      } else {
        // End break
        final breakEndRequest = BreakEndRequest(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
        );

        final breakEndResponse =
            await DriverStatusApiService.endBreak(breakEndRequest);

        // After ending break, refresh status from API to get latest state
        final updatedStatus = await DriverStatusApiService.getDriverStatus();

        // Emit success state with message from API, then update to loaded state
        emit(DriverBreakEndSuccess(
          status: updatedStatus,
          message: breakEndResponse.message,
        ));
        // Immediately emit loaded state so UI updates
        emit(DriverStatusLoaded(updatedStatus));
      }
    } on ApiException catch (e) {
      // On error, revert to previous state if it exists, otherwise emit error
      if (previousState != null) {
        // Revert to previous loaded state so toggle doesn't change
        emit(DriverStatusError(e.message));
        // After showing error, revert to previous state
        emit(DriverStatusLoaded(previousState));
      } else {
        emit(DriverStatusError(e.message));
      }
    } catch (e) {
      // Handle location errors or other exceptions
      final errorMessage = e.toString();
      String errorMsg;
      if (errorMessage.contains('location') ||
          errorMessage.contains('permission') ||
          errorMessage.contains('Location')) {
        errorMsg = errorMessage.contains('denied')
            ? 'Location permission is required to update break status. Please grant location permission in app settings.'
            : errorMessage.contains('disabled')
                ? 'Location services are disabled. Please enable location services.'
                : 'Failed to get location. Please try again.';
      } else {
        errorMsg =
            'Failed to ${event.isOnBreak ? "start" : "end"} break. Please try again.';
      }

      // On error, revert to previous state if it exists
      if (previousState != null) {
        emit(DriverStatusError(errorMsg));
        // After showing error, revert to previous state
        emit(DriverStatusLoaded(previousState));
      } else {
        emit(DriverStatusError(errorMsg));
      }
    }
  }
}
