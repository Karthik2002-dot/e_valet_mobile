class ClockOutResponse {
  final int shiftId;
  final DateTime clockInAt;
  final DateTime clockOutAt;
  final double totalHours;
  final int totalBreakMinutes;
  final String message;

  ClockOutResponse({
    required this.shiftId,
    required this.clockInAt,
    required this.clockOutAt,
    required this.totalHours,
    required this.totalBreakMinutes,
    required this.message,
  });

  factory ClockOutResponse.fromJson(Map<String, dynamic> json) {
    return ClockOutResponse(
      shiftId: json['shiftId'] as int? ?? 0,
      clockInAt: json['clockInAt'] != null
          ? DateTime.parse(json['clockInAt'] as String)
          : DateTime.now(),
      clockOutAt: json['clockOutAt'] != null
          ? DateTime.parse(json['clockOutAt'] as String)
          : DateTime.now(),
      totalHours: (json['totalHours'] as num?)?.toDouble() ?? 0.0,
      totalBreakMinutes: json['totalBreakMinutes'] as int? ?? 0,
      message: (json['message'] ?? '').toString(),
    );
  }
}
