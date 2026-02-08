abstract class WebSocketEvent {
  const WebSocketEvent();
}

/// Event to connect to WebSocket server
class ConnectWebSocket extends WebSocketEvent {
  final String url;
  final Map<String, dynamic>? auth;
  final Map<String, dynamic>? query;

  const ConnectWebSocket({
    required this.url,
    this.auth,
    this.query,
  });
}

/// Event to disconnect from WebSocket server
class DisconnectWebSocket extends WebSocketEvent {
  const DisconnectWebSocket();
}

/// Event to reconnect when app returns from background (uses last url/auth/query).
class ReconnectWebSocket extends WebSocketEvent {
  const ReconnectWebSocket();
}

/// Event to join a specific room
class JoinRoom extends WebSocketEvent {
  final String roomType;
  final String roomId;
  final Map<String, dynamic>? additionalData;

  const JoinRoom({
    required this.roomType,
    required this.roomId,
    this.additionalData,
  });

  /// Helper to create outlet room join event
  factory JoinRoom.outlet(String outletId) {
    return JoinRoom(
      roomType: 'outlet',
      roomId: outletId,
    );
  }

  String get roomName => '$roomType:$roomId';
}

/// Event to leave a specific room
class LeaveRoom extends WebSocketEvent {
  final String roomType;
  final String roomId;

  const LeaveRoom({
    required this.roomType,
    required this.roomId,
  });

  /// Helper to create outlet room leave event
  factory LeaveRoom.outlet(String outletId) {
    return LeaveRoom(
      roomType: 'outlet',
      roomId: outletId,
    );
  }

  String get roomName => '$roomType:$roomId';
}

/// Event to listen to a specific event
class ListenToEvent extends WebSocketEvent {
  final String eventName;

  const ListenToEvent(this.eventName);
}

/// Event to stop listening to a specific event
class StopListeningToEvent extends WebSocketEvent {
  final String eventName;

  const StopListeningToEvent(this.eventName);
}

/// Event to emit data to server
class EmitEvent extends WebSocketEvent {
  final String eventName;
  final dynamic data;

  const EmitEvent({
    required this.eventName,
    this.data,
  });
}
