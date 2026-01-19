class DriverStatus {
  final String status; // "ONLINE" or "OFFLINE"
  final int shiftId;
  final int outletId;
  final String outletName;
  final DateTime clockInAt;
  final int totalBreakMinutes;
  final DateTime? currentBreakStartedAt;

  DriverStatus({
    required this.status,
    required this.shiftId,
    required this.outletId,
    required this.outletName,
    required this.clockInAt,
    required this.totalBreakMinutes,
    this.currentBreakStartedAt,
  });

  factory DriverStatus.fromJson(Map<String, dynamic> json) {
    return DriverStatus(
      status: (json['status'] ?? '').toString(),
      shiftId: json['shiftId'] as int? ?? 0,
      outletId: json['outletId'] as int? ?? 0,
      outletName: (json['outletName'] ?? '').toString(),
      clockInAt: json['clockInAt'] != null
          ? DateTime.parse(json['clockInAt'] as String)
          : DateTime.now(),
      totalBreakMinutes: json['totalBreakMinutes'] as int? ?? 0,
      currentBreakStartedAt: json['currentBreakStartedAt'] != null
          ? DateTime.parse(json['currentBreakStartedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'shiftId': shiftId,
      'outletId': outletId,
      'outletName': outletName,
      'clockInAt': clockInAt.toIso8601String(),
      'totalBreakMinutes': totalBreakMinutes,
      'currentBreakStartedAt': currentBreakStartedAt?.toIso8601String(),
    };
  }

  bool get isOnline =>
      status.toUpperCase() == 'ONLINE' ||
      status.toUpperCase() == 'ON_BREAK' ||
      status.toUpperCase() == 'BREAK';
  bool get isOffline => status.toUpperCase() == 'OFFLINE';
  bool get isOnBreak =>
      status.toUpperCase() == 'ON_BREAK' || status.toUpperCase() == 'BREAK';
}
