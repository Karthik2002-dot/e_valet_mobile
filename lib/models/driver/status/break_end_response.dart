class BreakEndResponse {
  final int shiftId;
  final String status;
  final String message;

  BreakEndResponse({
    required this.shiftId,
    required this.status,
    required this.message,
  });

  factory BreakEndResponse.fromJson(Map<String, dynamic> json) {
    return BreakEndResponse(
      shiftId: json['shiftId'] as int? ?? 0,
      status: (json['status'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}
