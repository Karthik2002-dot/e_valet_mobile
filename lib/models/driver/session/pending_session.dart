class PendingSession {
  final String sessionId;
  final int cardNumber;
  final String status; // Can be "CHECKED_IN" or other status strings
  final String createdAt;
  final String? assignedAt;
  final int pendingForMinutes;
  final String? vehicleNumber;
  final String? customerPhone;
  final String? parkingLocation;
  final String? taskType;

  PendingSession({
    required this.sessionId,
    required this.cardNumber,
    required this.status,
    required this.createdAt,
    required this.pendingForMinutes,
    this.assignedAt,
    this.vehicleNumber,
    this.customerPhone,
    this.parkingLocation,
    this.taskType,
  });

  static const Set<String> _knownStatuses = {
    'ACCEPT',
    'ACCEPTED',
    'ARRIVED',
    'CHECKED_IN',
  };

  static String _normalizeStatusString(dynamic value) {
    if (value == null) {
      return '';
    }
    final normalized = value.toString().trim().toUpperCase();
    return normalized;
  }

  static String _extractStatus(dynamic rawStatus) {
    if (rawStatus is String) {
      return _normalizeStatusString(rawStatus);
    }

    if (rawStatus is Map) {
      const preferredKeys = [
        'status',
        'name',
        'value',
        'state',
        'code',
        'type',
      ];

      for (final key in preferredKeys) {
        if (rawStatus.containsKey(key)) {
          final extracted = _extractStatus(rawStatus[key]);
          if (extracted.isNotEmpty) {
            return extracted;
          }
        }
      }

      for (final value in rawStatus.values) {
        final normalized = _normalizeStatusString(value);
        if (_knownStatuses.contains(normalized)) {
          return normalized;
        }
        if (value is Map || value is List) {
          final extracted = _extractStatus(value);
          if (_knownStatuses.contains(extracted)) {
            return extracted;
          }
        }
      }
    }

    if (rawStatus is List) {
      for (final value in rawStatus) {
        final extracted = _extractStatus(value);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }
    }

    return '';
  }

  factory PendingSession.fromJson(Map<String, dynamic> json) {
    // Handle status - can be a string or an object with nested fields
    final statusString = _extractStatus(json['status']);

    return PendingSession(
      sessionId: (json['sessionId'] ?? '').toString(),
      cardNumber: json['cardNumber'] as int? ?? 0,
      status: statusString,
      createdAt: (json['createdAt'] ?? '').toString(),
      assignedAt: json['assignedAt']?.toString(),
      pendingForMinutes: json['pendingForMinutes'] as int? ?? 0,
      vehicleNumber: json['vehicleNumber']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      parkingLocation: json['parkingLocation']?.toString(),
      taskType: json['taskType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'cardNumber': cardNumber,
      'status': status,
      'createdAt': createdAt,
      'assignedAt': assignedAt,
      'pendingForMinutes': pendingForMinutes,
      if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
      if (customerPhone != null) 'customerPhone': customerPhone,
      if (parkingLocation != null) 'parkingLocation': parkingLocation,
      if (taskType != null) 'taskType': taskType,
    };
  }

  bool get isCheckedIn => status == 'CHECKED_IN';

  bool get isAccepted => status == 'ACCEPT' || status == 'ACCEPTED';

  bool get isArrived => status == 'ARRIVED';
}
