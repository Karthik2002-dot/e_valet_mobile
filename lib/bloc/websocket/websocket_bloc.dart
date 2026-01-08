import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/services/websocket/websocket_service.dart';
import 'websocket_event.dart';
import 'websocket_state.dart';

/// BLoC for managing WebSocket connection lifecycle
class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final WebSocketService _webSocketService = WebSocketService();
  final Set<String> _joinedRooms = {};
  StreamSubscription<bool>? _connectionSubscription;
  final Map<String, StreamSubscription<dynamic>> _eventSubscriptions = {};

  WebSocketBloc() : super(const WebSocketInitial()) {
    on<ConnectWebSocket>(_onConnectWebSocket);
    on<DisconnectWebSocket>(_onDisconnectWebSocket);
    on<JoinRoom>(_onJoinRoom);
    on<LeaveRoom>(_onLeaveRoom);
    on<ListenToEvent>(_onListenToEvent);
    on<StopListeningToEvent>(_onStopListeningToEvent);
    on<EmitEvent>(_onEmitEvent);
    on<_WebSocketConnectionEstablished>(_onConnectionEstablished);
    on<_WebSocketConnectionLost>(_onConnectionLost);
  }

  /// Get WebSocket service instance for direct access if needed
  WebSocketService get service => _webSocketService;

  /// Check if connected
  bool get isConnected => _webSocketService.isConnected;

  /// Get list of joined rooms
  Set<String> get joinedRooms => Set.unmodifiable(_joinedRooms);

  /// Connect to WebSocket server
  Future<void> _onConnectWebSocket(
    ConnectWebSocket event,
    Emitter<WebSocketState> emit,
  ) async {
    try {
      emit(const WebSocketConnecting());

      // Connect to WebSocket
      await _webSocketService.connect(
        url: event.url,
        auth: event.auth,
        query: event.query,
        autoConnect: true,
      );

      // Listen to connection status changes
      _connectionSubscription?.cancel();
      _connectionSubscription =
          _webSocketService.connectionStream.listen((isConnected) {
        if (isConnected) {
          final socketId = _webSocketService.socket?.id ?? 'unknown';
          add(const _WebSocketConnectionEstablished());
        } else {
          add(const _WebSocketConnectionLost());
        }
      });

      // Wait a bit for connection to establish
      await Future.delayed(const Duration(milliseconds: 500));

      if (_webSocketService.isConnected) {
        final socketId = _webSocketService.socket?.id ?? 'unknown';
        emit(WebSocketConnected(socketId: socketId));
      }
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      emit(WebSocketError(message: 'Connection failed', error: e));
    }
  }

  /// Disconnect from WebSocket server
  Future<void> _onDisconnectWebSocket(
    DisconnectWebSocket event,
    Emitter<WebSocketState> emit,
  ) async {
    try {
      // Cancel all event subscriptions
      for (var subscription in _eventSubscriptions.values) {
        await subscription.cancel();
      }
      _eventSubscriptions.clear();

      // Cancel connection subscription
      await _connectionSubscription?.cancel();
      _connectionSubscription = null;

      // Clear joined rooms
      _joinedRooms.clear();

      // Disconnect
      await _webSocketService.disconnect();

      emit(const WebSocketDisconnected(reason: 'User disconnected'));
    } catch (e) {
      print('Error disconnecting from WebSocket: $e');
      emit(WebSocketError(message: 'Disconnect failed', error: e));
    }
  }

  /// Join a room
  Future<void> _onJoinRoom(
    JoinRoom event,
    Emitter<WebSocketState> emit,
  ) async {
    if (!_webSocketService.isConnected) {
      print('Cannot join room: WebSocket not connected');
      return;
    }

    try {
      final roomName = event.roomName;
      // Emit subscribe event based on room type (matches NestJS @SubscribeMessage)
      final payload = event.additionalData ?? {};
      payload['${event.roomType}Id'] = event.roomId;

      // Use emitWithAck to get server confirmation
      try {
        final response = await _webSocketService.emitWithAck(
          'subscribe:${event.roomType}',
          payload,
          const Duration(seconds: 5),
        );
      } catch (e) {
        print('No response from subscription (continuing anyway): $e');
      }

      // Track joined room
      _joinedRooms.add(roomName);

      // Update state with joined room
      if (state is WebSocketConnected) {
        final currentState = state as WebSocketConnected;
        emit(currentState.copyWith(
          joinedRooms: _joinedRooms.toList(),
        ));
      }
    } catch (e) {
      print('Error joining room: $e');
    }
  }

  /// Leave a room
  Future<void> _onLeaveRoom(
    LeaveRoom event,
    Emitter<WebSocketState> emit,
  ) async {
    if (!_webSocketService.isConnected) {
      print('Cannot leave room: WebSocket not connected');
      return;
    }

    try {
      final roomName = event.roomName;
      // Emit unsubscribe event based on room type (matches NestJS @SubscribeMessage)
      _webSocketService.emit('unsubscribe:${event.roomType}', {
        '${event.roomType}Id': event.roomId,
      });

      // Remove from tracked rooms
      _joinedRooms.remove(roomName);

      // Update state with updated room list
      if (state is WebSocketConnected) {
        final currentState = state as WebSocketConnected;
        emit(currentState.copyWith(
          joinedRooms: _joinedRooms.toList(),
        ));
      }
    } catch (e) {
      print('Error leaving room: $e');
    }
  }

  /// Listen to a specific event
  Future<void> _onListenToEvent(
    ListenToEvent event,
    Emitter<WebSocketState> emit,
  ) async {
    if (_eventSubscriptions.containsKey(event.eventName)) {
      return;
    }

    try {
      final stream = _webSocketService.getEventStream(event.eventName);
      final subscription = stream.listen(
        (data) {
          // Events are handled by listeners in the app, not by the BLoC
        },
        onError: (error) {
          print('Error on event ${event.eventName}: $error');
        },
      );

      _eventSubscriptions[event.eventName] = subscription;
    } catch (e) {
      print('Error setting up listener for ${event.eventName}: $e');
    }
  }

  /// Stop listening to a specific event
  Future<void> _onStopListeningToEvent(
    StopListeningToEvent event,
    Emitter<WebSocketState> emit,
  ) async {
    if (!_eventSubscriptions.containsKey(event.eventName)) {
      return;
    }

    try {
      await _eventSubscriptions[event.eventName]?.cancel();
      _eventSubscriptions.remove(event.eventName);

      _webSocketService.disposeEventStream(event.eventName);
    } catch (e) {
      print('Error stopping listener for ${event.eventName}: $e');
    }
  }

  /// Emit an event to the server
  Future<void> _onEmitEvent(
    EmitEvent event,
    Emitter<WebSocketState> emit,
  ) async {
    if (!_webSocketService.isConnected) {
      print('Cannot emit event: WebSocket not connected');
      return;
    }

    try {
      _webSocketService.emit(event.eventName, event.data);
    } catch (e) {
      print('Error emitting event ${event.eventName}: $e');
    }
  }

  /// Handle connection established
  Future<void> _onConnectionEstablished(
    _WebSocketConnectionEstablished event,
    Emitter<WebSocketState> emit,
  ) async {
    final socketId = _webSocketService.socket?.id ?? 'unknown';
    emit(WebSocketConnected(
        socketId: socketId, joinedRooms: _joinedRooms.toList()));
  }

  /// Handle connection lost
  Future<void> _onConnectionLost(
    _WebSocketConnectionLost event,
    Emitter<WebSocketState> emit,
  ) async {
    emit(const WebSocketDisconnected(reason: 'Connection lost'));
  }

  @override
  Future<void> close() async {
    // Cancel all subscriptions
    await _connectionSubscription?.cancel();
    for (var subscription in _eventSubscriptions.values) {
      await subscription.cancel();
    }
    _eventSubscriptions.clear();

    return super.close();
  }
}

// Internal events for connection state changes
class _WebSocketConnectionEstablished extends WebSocketEvent {
  const _WebSocketConnectionEstablished();
}

class _WebSocketConnectionLost extends WebSocketEvent {
  const _WebSocketConnectionLost();
}
