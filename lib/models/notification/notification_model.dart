import 'package:equatable/equatable.dart';

/// Notification model representing a push notification
class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final NotificationPriority priority;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.priority = NotificationPriority.normal,
  });

  /// Create from Firebase RemoteMessage data
  factory NotificationModel.fromFirebase(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    return NotificationModel(
      id: data['id'] ??
          data['messageId'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? data['title'] ?? 'Notification',
      body: body ?? data['body'] ?? '',
      type: NotificationType.fromString(data['type']),
      data: data,
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      isRead: false,
      imageUrl: data['image_url'],
      priority: NotificationPriority.fromString(data['priority']),
    );
  }

  /// Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.fromString(json['type']),
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      priority: NotificationPriority.fromString(json['priority']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.value,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'priority': priority.value,
    };
  }

  /// Copy with method
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    NotificationPriority? priority,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        data,
        timestamp,
        isRead,
        imageUrl,
        priority,
      ];
}

/// Notification types for the valet system
enum NotificationType {
  retrievalRequest('retrieval_request'),
  driverAssigned('driver_assigned'),
  driverUpdate('driver_update'),
  vehicleReady('vehicle_ready'),
  vehicleDelivered('vehicle_delivered'),
  systemAlert('system_alert'),
  general('general'),
  unknown('unknown');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'retrieval_request':
        return NotificationType.retrievalRequest;
      case 'driver_assigned':
        return NotificationType.driverAssigned;
      case 'driver_update':
        return NotificationType.driverUpdate;
      case 'vehicle_ready':
        return NotificationType.vehicleReady;
      case 'vehicle_delivered':
        return NotificationType.vehicleDelivered;
      case 'system_alert':
        return NotificationType.systemAlert;
      case 'general':
        return NotificationType.general;
      default:
        return NotificationType.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.retrievalRequest:
        return 'Retrieval Request';
      case NotificationType.driverAssigned:
        return 'Driver Assigned';
      case NotificationType.driverUpdate:
        return 'Driver Update';
      case NotificationType.vehicleReady:
        return 'Vehicle Ready';
      case NotificationType.vehicleDelivered:
        return 'Vehicle Delivered';
      case NotificationType.systemAlert:
        return 'System Alert';
      case NotificationType.general:
        return 'General';
      case NotificationType.unknown:
        return 'Notification';
    }
  }
}

/// Notification priority levels
enum NotificationPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  final String value;
  const NotificationPriority(this.value);

  static NotificationPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }
}

/// Notification settings model for user preferences
class NotificationSettings extends Equatable {
  final bool enabled;
  final bool retrievalRequestEnabled;
  final bool driverUpdatesEnabled;
  final bool vehicleStatusEnabled;
  final bool systemAlertsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationSettings({
    this.enabled = true,
    this.retrievalRequestEnabled = true,
    this.driverUpdatesEnabled = true,
    this.vehicleStatusEnabled = true,
    this.systemAlertsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      retrievalRequestEnabled: json['retrievalRequestEnabled'] as bool? ?? true,
      driverUpdatesEnabled: json['driverUpdatesEnabled'] as bool? ?? true,
      vehicleStatusEnabled: json['vehicleStatusEnabled'] as bool? ?? true,
      systemAlertsEnabled: json['systemAlertsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'retrievalRequestEnabled': retrievalRequestEnabled,
      'driverUpdatesEnabled': driverUpdatesEnabled,
      'vehicleStatusEnabled': vehicleStatusEnabled,
      'systemAlertsEnabled': systemAlertsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? enabled,
    bool? retrievalRequestEnabled,
    bool? driverUpdatesEnabled,
    bool? vehicleStatusEnabled,
    bool? systemAlertsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      retrievalRequestEnabled:
          retrievalRequestEnabled ?? this.retrievalRequestEnabled,
      driverUpdatesEnabled: driverUpdatesEnabled ?? this.driverUpdatesEnabled,
      vehicleStatusEnabled: vehicleStatusEnabled ?? this.vehicleStatusEnabled,
      systemAlertsEnabled: systemAlertsEnabled ?? this.systemAlertsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        retrievalRequestEnabled,
        driverUpdatesEnabled,
        vehicleStatusEnabled,
        systemAlertsEnabled,
        soundEnabled,
        vibrationEnabled,
      ];
}
