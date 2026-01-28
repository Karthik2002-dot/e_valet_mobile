import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

/// WebSocket service for managing Socket.IO connections
class WebSocketService {
  /// Singleton instance
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  /// Socket instance
  IO.Socket? _socket;

  /// Connection status stream
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  /// Authentication error stream
  final StreamController<Map<String, dynamic>> _authErrorController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Custom event stream controller for dynamic event handling
  final Map<String, StreamController<dynamic>> _eventControllers = {};

  /// Get the socket instance
  IO.Socket? get socket => _socket;

  /// Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;

  /// Stream to listen to connection status changes
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Stream to listen to authentication errors
  Stream<Map<String, dynamic>> get authErrorStream =>
      _authErrorController.stream;

  /// Initialize and connect to WebSocket server
  Future<void> connect({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? auth,
    bool autoConnect = true,
    int reconnectionAttempts = 5,
    int reconnectionDelay = 2000,
    int reconnectionDelayMax = 10000,
    bool randomizationFactor = true,
    int timeout = 20000,
  }) async {
    try {
      // Disconnect existing socket if any
      if (_socket != null && _socket!.connected) {
        print('Disconnecting existing socket before reconnecting');
        await disconnect();
      }

      print('Connecting to WebSocket: $url');

      // Build socket options
      final optionBuilder = IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setReconnectionAttempts(reconnectionAttempts)
          .setReconnectionDelay(reconnectionDelay)
          .setReconnectionDelayMax(reconnectionDelayMax)
          .setTimeout(timeout)
          .enableForceNew()
          .enableReconnection();

      // Add query parameters if provided
      if (query != null && query.isNotEmpty) {
        optionBuilder.setQuery(query);

        // If query contains 'token', also add it as Authorization header
        if (query.containsKey('token')) {
          final token = query['token'];
          optionBuilder.setExtraHeaders({
            'Authorization': 'Bearer $token',
          });
        }
      }

      // Add auth as query parameters or extraHeaders
      if (auth != null && auth.isNotEmpty) {
        // Try to set auth token in multiple ways for compatibility
        try {
          optionBuilder.setAuth(auth);
        } catch (e) {
          print('Could not set auth directly, using query params: $e');
        }

        // Also add as query parameter for better compatibility
        final authQuery = query ?? {};
        authQuery.addAll(auth);
        optionBuilder.setQuery(authQuery);
      }

      // Configure socket
      _socket = IO.io(url, optionBuilder.build());

      // Setup default event listeners
      _setupDefaultListeners();

      // Connect if autoConnect is true
      if (autoConnect) {
        print('Auto-connecting socket...');
        _socket!.connect();
      }
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      rethrow;
    }
  }

  /// Setup default socket event listeners
  void _setupDefaultListeners() {
    _socket?.onConnect((_) {
      print('WebSocket connected successfully');
      _connectionController.add(true);
    });

    _socket?.onDisconnect((data) {
      print('WebSocket disconnected: $data');
      _connectionController.add(false);
    });

    _socket?.onConnectError((error) {
      print('WebSocket connection error: $error');
      _connectionController.add(false);
      
      // Check if error is authentication-related
      _checkAndHandleAuthError(error);
    });

    _socket?.onConnectTimeout((_) {
      print('WebSocket connection timeout');
      _connectionController.add(false);
    });

    _socket?.onError((error) {
      print('WebSocket error: $error');
      
      // Check if error is authentication-related
      _checkAndHandleAuthError(error);
    });

    _socket?.onReconnect((attempt) {
      print('WebSocket reconnecting (attempt: $attempt)');
    });

    _socket?.onReconnectAttempt((attempt) {
      print('WebSocket reconnection attempt: $attempt');
    });

    _socket?.onReconnectError((error) {
      print('WebSocket reconnection error: $error');
    });

    _socket?.onReconnectFailed((_) {
      print('WebSocket reconnection failed - giving up');
      _connectionController.add(false);
    });

    _socket?.onPing((_) {
      // Uncomment for debugging
      // print('WebSocket ping');
    });

    _socket?.onPong((_) {
      // Uncomment for debugging
      // print('WebSocket pong');
    });

    // Listen to custom 'exception' event from server (NestJS gateway exception filter)
    _socket?.on('exception', (data) {
      print('WebSocket exception from server: $data');
      _checkAndHandleAuthError(data);
    });
  }

  /// Check if error is authentication-related and emit to auth error stream
  void _checkAndHandleAuthError(dynamic error) {
    try {
      String errorMessage = '';
      int? statusCode;

      if (error is Map) {
        errorMessage = error['message']?.toString() ?? '';
        statusCode = error['statusCode'] as int?;
      } else if (error is String) {
        errorMessage = error;
      }

      // Check for authentication error indicators
      final isAuthError = statusCode == 401 ||
          statusCode == 403 ||
          errorMessage.toLowerCase().contains('unauthorized') ||
          errorMessage.toLowerCase().contains('authentication') ||
          errorMessage.toLowerCase().contains('token') ||
          errorMessage.toLowerCase().contains('forbidden');

      if (isAuthError) {
        print('Authentication error detected in WebSocket: $errorMessage');
        if (!_authErrorController.isClosed) {
          _authErrorController.add({
            'error': errorMessage,
            'statusCode': statusCode,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      print('Error checking auth error: $e');
    }
  }

  /// Emit an event to the server
  void emit(String event, [dynamic data]) {
    if (_socket == null || !_socket!.connected) {
      print('Cannot emit event "$event": Socket not connected');
      return;
    }

    _socket!.emit(event, data);
  }

  /// Emit an event and wait for acknowledgment
  Future<dynamic> emitWithAck(
    String event, [
    dynamic data,
    Duration timeout = const Duration(seconds: 10),
  ]) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    final completer = Completer<dynamic>();

    _socket!.emitWithAck(event, data, ack: (response) {
      if (!completer.isCompleted) {
        completer.complete(response);
      }
    });

    // Add timeout
    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException(
          'Timeout waiting for acknowledgment on event: $event',
        ));
      }
    });

    return completer.future;
  }

  /// Listen to a specific event
  void on(String event, Function(dynamic) callback) {
    if (_socket == null) {
      print('Cannot listen to event "$event": Socket not initialized');
      return;
    }

    _socket!.on(event, callback);
  }

  /// Listen to a specific event once
  void once(String event, Function(dynamic) callback) {
    if (_socket == null) {
      print('Cannot listen to event "$event": Socket not initialized');
      return;
    }

    _socket!.once(event, callback);
  }

  /// Remove listener for a specific event
  void off(String event, [Function(dynamic)? callback]) {
    if (_socket == null) {
      print('Cannot remove listener for "$event": Socket not initialized');
      return;
    }

    if (callback != null) {
      _socket!.off(event, callback);
    } else {
      _socket!.off(event);
    }
  }

  /// Get a stream for a specific event
  Stream<dynamic> getEventStream(String event) {
    if (!_eventControllers.containsKey(event)) {
      _eventControllers[event] = StreamController<dynamic>.broadcast();
      on(event, (data) {
        if (!_eventControllers[event]!.isClosed) {
          _eventControllers[event]!.add(data);
        }
      });
    }
    return _eventControllers[event]!.stream;
  }

  /// Dispose event stream
  void disposeEventStream(String event) {
    if (_eventControllers.containsKey(event)) {
      _eventControllers[event]!.close();
      _eventControllers.remove(event);
      off(event);
    }
  }

  /// Manually connect the socket
  void manualConnect() {
    if (_socket == null) {
      print('Cannot connect: Socket not initialized');
      return;
    }

    if (!_socket!.connected) {
      _socket!.connect();
    } else {
      print('Socket already connected');
    }
  }

  /// Disconnect the socket
  Future<void> disconnect() async {
    if (_socket == null) {
      print('Socket already null');
      return;
    }

    // Close all event controllers
    for (var controller in _eventControllers.values) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _eventControllers.clear();

    // Disconnect socket
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    _connectionController.add(false);
  }

  /// Dispose the service and clean up resources
  Future<void> dispose() async {
    await disconnect();
    if (!_connectionController.isClosed) {
      await _connectionController.close();
    }
    if (!_authErrorController.isClosed) {
      await _authErrorController.close();
    }
  }

  /// Reconnect the socket
  Future<void> reconnect() async {
    await disconnect();
    manualConnect();
  }

  /// Join a room (for Socket.IO room-based events)
  void joinRoom(String roomName, {Map<String, dynamic>? data}) {
    if (_socket == null || !_socket!.connected) {
      print('Cannot join room "$roomName": Socket not connected');
      return;
    }

    final payload = data ?? {};
    payload['room'] = roomName;
    emit('join_room', payload);
  }

  /// Leave a room (for Socket.IO room-based events)
  void leaveRoom(String roomName) {
    if (_socket == null || !_socket!.connected) {
      print('Cannot leave room "$roomName": Socket not connected');
      return;
    }

    emit('leave_room', {'room': roomName});
  }
}
