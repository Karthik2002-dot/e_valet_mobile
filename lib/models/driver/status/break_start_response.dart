class BreakStartResponse {
  final int shiftId;
  final String status;
  final String message;

  BreakStartResponse({
    required this.shiftId,
    required this.status,
    required this.message,
  });

  factory BreakStartResponse.fromJson(Map<String, dynamic> json) {
    return BreakStartResponse(
      shiftId: json['shiftId'] as int? ?? 0,
      status: (json['status'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}
