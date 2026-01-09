import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/assigned_sessions_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';

part 'assigned_sessions_background_event.dart';
part 'assigned_sessions_background_state.dart';

class AssignedSessionsBackgroundBloc extends Bloc<
    AssignedSessionsBackgroundEvent, AssignedSessionsBackgroundState> {
  final WebSocketBloc? webSocketBloc;
  StreamSubscription<dynamic>? _retrievalAssignedSubscription;
  StreamSubscription<bool>? _webSocketConnectionSubscription;

  AssignedSessionsBackgroundBloc({this.webSocketBloc})
      : super(const AssignedSessionsBackgroundInitial()) {
    on<StartAssignedSessionsPolling>(_onStartPolling);
    on<StopAssignedSessionsPolling>(_onStopPolling);
    on<RefreshAssignedSessions>(_onRefreshAssignedSessions);
    on<ReinitializeWebSocket>(_onReinitializeWebSocket);
    on<_PollAssignedSessions>(_onPollSessions);

    // Setup WebSocket listeners and connection monitoring
    _setupWebSocketConnectionMonitoring();

    // Fetch existing assigned sessions on startup
    _fetchExistingAssignedSessions();

    // Setup hot reload detection
    _setupHotReloadDetection();
  }

  void _setupHotReloadDetection() {
    // This will help detect if the app was hot reloaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (webSocketBloc != null && webSocketBloc!.isConnected) {
        _setupRetrievalAssignedListener();
      }
    });
  }

  /// Fetch existing assigned sessions when bloc starts
  void _fetchExistingAssignedSessions() {
    // Use addPostFrameCallback to ensure bloc is fully initialized
    Future.microtask(() {
      add(const _PollAssignedSessions());
    });
  }

  /// Monitor WebSocket connection and setup listeners when connected
  void _setupWebSocketConnectionMonitoring() {
    if (webSocketBloc == null) {
      print(
        'WebSocketBloc not provided to AssignedSessionsBackgroundBloc. '
        'No WebSocket functionality available.',
      );
      return;
    }

    // Listen to WebSocket connection status changes
    _webSocketConnectionSubscription =
        webSocketBloc!.service.connectionStream.listen((isConnected) {
      if (isConnected) {
        // WebSocket connected - setup the event listener
        _setupRetrievalAssignedListener();
      } else {
        // WebSocket disconnected - cleanup the listener
        _cleanupRetrievalAssignedListener();
      }
    });

    // If already connected, setup listener immediately
    if (webSocketBloc!.isConnected) {
      _setupRetrievalAssignedListener();
    }
  }

  /// Setup the retrieval:assigned event listener
  void _setupRetrievalAssignedListener() {
    // Clean up any existing listener first
    _cleanupRetrievalAssignedListener();

    try {
      final retrievalAssignedStream =
          webSocketBloc!.service.getEventStream('retrieval:assigned');

      _retrievalAssignedSubscription = retrievalAssignedStream.listen(
        (data) {
          // When a retrieval is assigned, fetch the latest assigned sessions
          add(const _PollAssignedSessions());
        },
        onError: (error) {
          print('Error listening to retrieval assigned updates: $error');
        },
      );
    } catch (e) {
      print('Error setting up retrieval:assigned listener: $e');
    }
  }

  /// Cleanup the retrieval:assigned event listener
  void _cleanupRetrievalAssignedListener() {
    if (_retrievalAssignedSubscription != null) {
      _retrievalAssignedSubscription?.cancel();
      _retrievalAssignedSubscription = null;
    }
  }

  void _onStartPolling(
    StartAssignedSessionsPolling event,
    Emitter<AssignedSessionsBackgroundState> emit,
  ) {
    // Polling is no longer used - WebSocket handles real-time updates
  }

  void _onStopPolling(
    StopAssignedSessionsPolling event,
    Emitter<AssignedSessionsBackgroundState> emit,
  ) {
    // Polling is no longer used - nothing to stop
  }

  void _onRefreshAssignedSessions(
    RefreshAssignedSessions event,
    Emitter<AssignedSessionsBackgroundState> emit,
  ) {
    // Public method to manually refresh assigned sessions
    add(const _PollAssignedSessions());
  }

  void _onReinitializeWebSocket(
    ReinitializeWebSocket event,
    Emitter<AssignedSessionsBackgroundState> emit,
  ) {
    // Force cleanup and re-setup
    _cleanupRetrievalAssignedListener();
    _setupWebSocketConnectionMonitoring();

    // Force immediate refresh
    add(const _PollAssignedSessions());
  }

  void _onPollSessions(
    _PollAssignedSessions event,
    Emitter<AssignedSessionsBackgroundState> emit,
  ) async {
    try {
      final sessions = await AssignedSessionsApiService.fetchAssignedSessions();

      // Always emit new data - ensures UI updates for both initial load and WebSocket events
      emit(AssignedSessionsBackgroundData(sessions));
    } catch (e) {
      print('Failed to fetch assigned sessions: $e');
    }
  }

  @override
  Future<void> close() {
    // Cancel WebSocket subscriptions
    _retrievalAssignedSubscription?.cancel();
    _webSocketConnectionSubscription?.cancel();
    return super.close();
  }
}
