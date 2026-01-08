abstract class WebSocketState {
  const WebSocketState();
}

/// Initial state before any connection attempt
class WebSocketInitial extends WebSocketState {
  const WebSocketInitial();
}

/// WebSocket is attempting to connect
class WebSocketConnecting extends WebSocketState {
  const WebSocketConnecting();
}

/// WebSocket is connected
class WebSocketConnected extends WebSocketState {
  final String socketId;
  final List<String> joinedRooms;

  const WebSocketConnected({
    required this.socketId,
    this.joinedRooms = const [],
  });

  WebSocketConnected copyWith({
    String? socketId,
    List<String>? joinedRooms,
  }) {
    return WebSocketConnected(
      socketId: socketId ?? this.socketId,
      joinedRooms: joinedRooms ?? this.joinedRooms,
    );
  }

  List<Object> get props => [socketId, joinedRooms];
}

/// WebSocket is disconnected
class WebSocketDisconnected extends WebSocketState {
  final String? reason;

  const WebSocketDisconnected({this.reason});

  List<Object?> get props => [reason];
}

/// WebSocket connection error
class WebSocketError extends WebSocketState {
  final String message;
  final dynamic error;

  const WebSocketError({
    required this.message,
    this.error,
  });

  List<Object?> get props => [message, error];
}

/// WebSocket reconnecting
class WebSocketReconnecting extends WebSocketState {
  final int attemptNumber;

  const WebSocketReconnecting({required this.attemptNumber});

  List<Object> get props => [attemptNumber];
}
