import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/pass_available_drivers_api_service.dart';
import 'package:niloufer_valet_mobile/models/driver/session/pass_available_driver.dart';
import 'pass_available_drivers_event.dart';
import 'pass_available_drivers_state.dart';

class PassAvailableDriversBloc
    extends Bloc<PassAvailableDriversEvent, PassAvailableDriversState> {
  PassAvailableDriversBloc() : super(const PassAvailableDriversInitial()) {
    on<FetchPassAvailableDrivers>(_onFetch);
    on<PassSessionToDriver>(_onPass);
  }

  Future<void> _onFetch(
    FetchPassAvailableDrivers event,
    Emitter<PassAvailableDriversState> emit,
  ) async {
    emit(const PassAvailableDriversLoading());
    try {
      final drivers = await PassAvailableDriversApiService.getAvailableDrivers(
        sessionId: event.sessionId,
      );
      emit(PassAvailableDriversLoaded(drivers));
    } catch (e) {
      final msg = e is Exception ? e.toString() : 'Failed to load drivers';
      emit(PassAvailableDriversError(msg));
    }
  }

  Future<void> _onPass(
    PassSessionToDriver event,
    Emitter<PassAvailableDriversState> emit,
  ) async {
    // Keep the current driver list visible while the call is in-flight
    final currentDrivers = _currentDrivers();
    emit(PassingSessionToDriver(
      driverId: event.driverId,
      drivers: currentDrivers,
    ));

    try {
      final message = await PassAvailableDriversApiService.passSessionToDriver(
        sessionId: event.sessionId,
        driverId: event.driverId,
      );
      emit(SessionPassedToDriver(message));
    } catch (e) {
      final msg = e is Exception ? e.toString() : 'Failed to pass session';
      emit(PassToDriverError(message: msg, drivers: currentDrivers));
    }
  }

  List<PassAvailableDriver> _currentDrivers() {
    final s = state;
    if (s is PassAvailableDriversLoaded) return s.drivers;
    if (s is PassingSessionToDriver) return s.drivers;
    if (s is PassToDriverError) return s.drivers;
    return [];
  }
}
