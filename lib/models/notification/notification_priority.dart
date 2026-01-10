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

