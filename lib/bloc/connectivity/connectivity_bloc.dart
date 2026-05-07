import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';
import 'package:niloufer_valet_mobile/services/offline_sync/offline_parking_service.dart';
import 'package:niloufer_valet_mobile/services/connectivity/driver_connectivity_log_service.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _connectivityFlushTimer;

  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<CheckConnectivity>(_onCheckConnectivity);
    on<ConnectivityChanged>(_onConnectivityChanged);

    // Initial check
    add(CheckConnectivity());

    // Listen for changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
      add(ConnectivityChanged(results));
    });

    _connectivityFlushTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(DriverConnectivityLogService.instance.tryFlushIfDue());
    });
  }

  Future<void> _onCheckConnectivity(
      CheckConnectivity event, Emitter<ConnectivityState> emit) async {
    final results = await _connectivity.checkConnectivity();
    _updateState(results, emit);
  }

  void _onConnectivityChanged(
      ConnectivityChanged event, Emitter<ConnectivityState> emit) {
    _updateState(event.results, emit);
  }

  void _updateState(
      List<ConnectivityResult> results, Emitter<ConnectivityState> emit) {
    unawaited(
      DriverConnectivityLogService.instance.handleConnectivityResults(results),
    );

    bool isOffline =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    if (isOffline) {
      emit(ConnectivityOffline());
    } else {
      // Trigger sync immediately when back online
      OfflineParkingService.syncPendingData();
      emit(ConnectivityOnline());
      unawaited(DriverConnectivityLogService.instance.tryFlushIfDue());
    }
  }

  @override
  Future<void> close() {
    _connectivityFlushTimer?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
