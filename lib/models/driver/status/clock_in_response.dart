class ClockInResponse {
  final int shiftId;
  final String status;
  final int outletId;
  final String outletName;
  final DateTime clockInAt;
  final String message;

  ClockInResponse({
    required this.shiftId,
    required this.status,
    required this.outletId,
    required this.outletName,
    required this.clockInAt,
    required this.message,
  });

  factory ClockInResponse.fromJson(Map<String, dynamic> json) {
    return ClockInResponse(
      shiftId: json['shiftId'] as int? ?? 0,
      status: (json['status'] ?? '').toString(),
      outletId: json['outletId'] as int? ?? 0,
      outletName: (json['outletName'] ?? '').toString(),
      clockInAt: json['clockInAt'] != null
          ? DateTime.parse(json['clockInAt'] as String)
          : DateTime.now(),
      message: (json['message'] ?? '').toString(),
    );
  }
}
