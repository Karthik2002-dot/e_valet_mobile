class CancelAssignmentResponse {
  final String sessionId;
  final String status;
  final String message;
  final String cancelledAt;

  CancelAssignmentResponse({
    required this.sessionId,
    required this.status,
    required this.message,
    required this.cancelledAt,
  });

  factory CancelAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return CancelAssignmentResponse(
      sessionId: json['sessionId'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      cancelledAt: json['cancelledAt'] as String,
    );
  }
}
