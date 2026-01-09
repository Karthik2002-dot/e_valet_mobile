import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'local_notification_service.dart';

/// Top-level function to handle background messages
/// Must be a top-level function (not a class method)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Background message received: ${message.messageId}');
  log('Title: ${message.notification?.title}');
  log('Body: ${message.notification?.body}');
  log('Data: ${message.data}');
}

class FirebaseMessagingService implements NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  
  final StreamController<Map<String, dynamic>> _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Navigation key for global navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<void> initialize() async {
    try {
      log('Initializing Firebase Messaging Service...');

      // Initialize local notifications
      await _localNotificationService.initialize();

      // Request notification permissions
      await requestPermission();

      // Get FCM token
      final token = await getToken();
      log('FCM Token: $token');

      // Setup message handlers
      _setupMessageHandlers();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        log('FCM Token refreshed: $newToken');
        // TODO: Send updated token to backend
        _messageStreamController.add({
          'type': 'token_refresh',
          'token': newToken,
        });
      });

      log('Firebase Messaging Service initialized successfully');
    } catch (e) {
      log('Error initializing Firebase Messaging Service: $e');
      rethrow;
    }
  }

  @override
  Future<void> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        log('User granted provisional notification permission');
      } else {
        log('User declined or has not accepted notification permission');
      }
    } catch (e) {
      log('Error requesting notification permission: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      log('FCM Token retrieved: $token');
      return token;
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>> get onMessageReceived => _messageStreamController.stream;

  @override
  Future<void> handleBackgroundMessage(Map<String, dynamic> message) async {
    try {
      log('Handling background message: $message');
      
      // Process the message based on type
      final notificationType = message['type'] as String?;
      
      // Add to stream for BLoC to handle
      _messageStreamController.add(message);
      
      // Navigate if needed based on notification type
      _handleNavigation(notificationType, message);
    } catch (e) {
      log('Error handling background message: $e');
    }
  }

  /// Setup handlers for different app states
  void _setupMessageHandlers() {
    // Foreground messages (app is open and active)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message received: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Background messages (app is in background but not terminated)
    // User taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Notification opened app from background: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Terminated state (app was completely closed)
    // Check if app was opened from a notification
    _checkInitialMessage();
  }

  /// Handle messages when app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      log('Processing foreground message...');
      
      final notification = message.notification;
      final data = message.data;

      // Show local notification when app is in foreground
      if (notification != null) {
        _localNotificationService.showNotification(
          id: message.hashCode,
          title: notification.title ?? 'New Notification',
          body: notification.body ?? '',
          payload: message.data,
        );
      }

      // Add to stream for BLoC to handle
      _messageStreamController.add({
        'messageId': message.messageId,
        'title': notification?.title,
        'body': notification?.body,
        'data': data,
        'type': data['type'],
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      log('Error handling foreground message: $e');
    }
  }

  /// Handle when user taps on notification
  void _handleNotificationTap(RemoteMessage message) {
    try {
      log('Processing notification tap...');
      
      final data = message.data;
      final notificationType = data['type'] as String?;

      // Add to stream
      _messageStreamController.add({
        'messageId': message.messageId,
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': data,
        'type': notificationType,
        'action': 'tap',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Navigate to appropriate screen
      _handleNavigation(notificationType, data);
    } catch (e) {
      log('Error handling notification tap: $e');
    }
  }

  /// Check if app was opened from a terminated state by tapping notification
  Future<void> _checkInitialMessage() async {
    try {
      final RemoteMessage? message = await _firebaseMessaging.getInitialMessage();
      
      if (message != null) {
        log('App opened from terminated state via notification: ${message.messageId}');
        
        // Delay to ensure app is fully initialized
        await Future.delayed(const Duration(seconds: 2));
        
        _handleNotificationTap(message);
      }
    } catch (e) {
      log('Error checking initial message: $e');
    }
  }

  /// Navigate to appropriate screen based on notification type
  void _handleNavigation(String? type, Map<String, dynamic> data) {
    if (type == null || navigatorKey.currentContext == null) return;

    try {
      log('Navigating based on notification type: $type');
      
      switch (type) {
        case 'retrieval_request':
          _navigateToRetrievalRequest(data);
          break;
        case 'driver_assigned':
          _navigateToDriverDetails(data);
          break;
        case 'vehicle_ready':
          _navigateToVehicleStatus(data);
          break;
        case 'vehicle_delivered':
          _navigateToDeliveryConfirmation(data);
          break;
        case 'system_alert':
          _navigateToNotifications(data);
          break;
        default:
          log('Unknown notification type: $type');
          _navigateToNotifications(data);
      }
    } catch (e) {
      log('Error during navigation: $e');
    }
  }

  /// Navigation methods for different notification types
  void _navigateToRetrievalRequest(Map<String, dynamic> data) {
    final requestId = data['request_id'] as String?;
    if (requestId == null) return;
    
    log('Navigating to retrieval request: $requestId');
    // TODO: Implement navigation to retrieval request screen
    // navigatorKey.currentState?.pushNamed('/retrieval-request', arguments: requestId);
  }

  void _navigateToDriverDetails(Map<String, dynamic> data) {
    final driverId = data['driver_id'] as String?;
    if (driverId == null) return;
    
    log('Navigating to driver details: $driverId');
    // TODO: Implement navigation to driver details screen
    // navigatorKey.currentState?.pushNamed('/driver-details', arguments: driverId);
  }

  void _navigateToVehicleStatus(Map<String, dynamic> data) {
    final vehicleId = data['vehicle_id'] as String?;
    if (vehicleId == null) return;
    
    log('Navigating to vehicle status: $vehicleId');
    // TODO: Implement navigation to vehicle status screen
    // navigatorKey.currentState?.pushNamed('/vehicle-status', arguments: vehicleId);
  }

  void _navigateToDeliveryConfirmation(Map<String, dynamic> data) {
    final deliveryId = data['delivery_id'] as String?;
    if (deliveryId == null) return;
    
    log('Navigating to delivery confirmation: $deliveryId');
    // TODO: Implement navigation to delivery confirmation screen
    // navigatorKey.currentState?.pushNamed('/delivery-confirmation', arguments: deliveryId);
  }

  void _navigateToNotifications(Map<String, dynamic> data) {
    log('Navigating to notifications screen');
    // TODO: Implement navigation to notifications list screen
    // navigatorKey.currentState?.pushNamed('/notifications');
  }

  /// Subscribe to specific topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Delete FCM token (useful for logout)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      log('FCM token deleted');
    } catch (e) {
      log('Error deleting FCM token: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _messageStreamController.close();
  }
}
