import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

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
    if (results.contains(ConnectivityResult.none) && results.length == 1) {
      emit(ConnectivityOffline());
    } else {
      emit(ConnectivityOnline());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
