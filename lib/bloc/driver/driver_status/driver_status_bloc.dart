import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/driver_status_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

class DriverStatusBloc
    extends Bloc<DriverStatusEvent, DriverStatusState> {
  DriverStatusBloc() : super(const DriverStatusInitial()) {
    on<DriverStatusStarted>(_onStarted);
    on<DriverStatusRefreshed>(_onRefreshed);
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
}
