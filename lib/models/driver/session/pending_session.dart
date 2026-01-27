class ParkedBy {
  final String userId;
  final String name;
  final String phone;

  ParkedBy({
    required this.userId,
    required this.name,
    required this.phone,
  });

  factory ParkedBy.fromJson(Map<String, dynamic> json) {
    return ParkedBy(
      userId: (json['userId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
    };
  }
}

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
  final ParkedBy? parkedBy;
  final List<dynamic> photos;

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
    this.parkedBy,
    this.photos = const [],
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

    // Handle parkedBy - can be null or an object
    ParkedBy? parkedBy;
    if (json['parkedBy'] != null && json['parkedBy'] is Map) {
      parkedBy = ParkedBy.fromJson(json['parkedBy'] as Map<String, dynamic>);
    }

    // Handle photos - can be null or a list
    List<dynamic> photos = [];
    if (json['photos'] != null && json['photos'] is List) {
      photos = json['photos'] as List;
    }

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
      parkedBy: parkedBy,
      photos: photos,
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
      if (parkedBy != null) 'parkedBy': parkedBy!.toJson(),
      'photos': photos,
    };
  }

  bool get isCheckedIn => status == 'CHECKED_IN';

  bool get isAccepted => status == 'ACCEPT' || status == 'ACCEPTED';

  bool get isArrived => status == 'ARRIVED';
}
