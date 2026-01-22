class PendingSession {
  final String sessionId;
  final int cardNumber;
  final String status; // Can be "CHECKED_IN" or other status strings
  final String createdAt;
  final int pendingForMinutes;
  final String? vehicleNumber;

  PendingSession({
    required this.sessionId,
    required this.cardNumber,
    required this.status,
    required this.createdAt,
    required this.pendingForMinutes,
    this.vehicleNumber,
  });

  factory PendingSession.fromJson(Map<String, dynamic> json) {
    // Handle status - can be a string or an object
    String statusString = '';
    final rawStatus = json['status'];
    if (rawStatus is String) {
      statusString = rawStatus;
    } else if (rawStatus is Map) {
      // If status is an object, try to extract a status field or use empty string
      statusString = (rawStatus['status'] ?? '').toString();
    }

    return PendingSession(
      sessionId: (json['sessionId'] ?? '').toString(),
      cardNumber: json['cardNumber'] as int? ?? 0,
      status: statusString,
      createdAt: (json['createdAt'] ?? '').toString(),
      pendingForMinutes: json['pendingForMinutes'] as int? ?? 0,
      vehicleNumber: json['vehicleNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'cardNumber': cardNumber,
      'status': status,
      'createdAt': createdAt,
      'pendingForMinutes': pendingForMinutes,
      if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
    };
  }

  bool get isCheckedIn => status == 'CHECKED_IN';
}
