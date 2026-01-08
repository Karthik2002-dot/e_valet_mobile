import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/assigned_sessions_api_service.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';

part 'assigned_sessions_background_event.dart';
part 'assigned_sessions_background_state.dart';

class AssignedSessionsBackgroundBloc extends Bloc<
    AssignedSessionsBackgroundEvent, AssignedSessionsBackgroundState> {
  Timer? _pollingTimer;
  List<AssignedSession>? _lastSessions;

  AssignedSessionsBackgroundBloc()
      : super(const AssignedSessionsBackgroundInitial()) {
    on<StartAssignedSessionsPolling>(_onStartPolling);
    on<StopAssignedSessionsPolling>(_onStopPolling);
    on<_PollAssignedSessions>(_onPollSessions);

    // Start polling immediately when bloc is created
    _startPolling();
  }

  void _onStartPolling(
    StartAssignedSessionsPolling event,
    Emitter<AssignedSessionsBackgroundState> emit,
  ) {
    _startPolling();
  }

  void _onStopPolling(
    StopAssignedSessionsPolling event,
    Emitter<AssignedSessionsBackgroundState> emit,
  ) {
    _stopPolling();
  }

  void _onPollSessions(
    _PollAssignedSessions event,
    Emitter<AssignedSessionsBackgroundState> emit,
  ) async {
    try {
      final sessions = await AssignedSessionsApiService.fetchAssignedSessions();

      // Only emit new data if sessions have actually changed
      if (_hasSessionsChanged(sessions)) {
        _lastSessions = List.from(sessions);
        emit(AssignedSessionsBackgroundData(sessions));
      }

      // Continue polling
      _startPolling();
    } catch (e) {
      print('❌ Failed to poll assigned sessions: $e');
      // Continue polling even on error
      _startPolling();
    }
  }

  void _startPolling() {
    _stopPolling(); // Cancel any existing timer

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      add(const _PollAssignedSessions());
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  bool _hasSessionsChanged(List<AssignedSession> newSessions) {
    // If we don't have previous data, consider it changed
    if (_lastSessions == null) return true;

    // If lengths are different, data changed
    if (_lastSessions!.length != newSessions.length) return true;

    // Compare session IDs to check if data actually changed
    for (int i = 0; i < newSessions.length; i++) {
      if (newSessions[i].id != _lastSessions![i].id) {
        return true;
      }
    }

    // Data is the same
    return false;
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
