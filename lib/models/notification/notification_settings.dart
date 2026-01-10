import 'package:equatable/equatable.dart';

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
