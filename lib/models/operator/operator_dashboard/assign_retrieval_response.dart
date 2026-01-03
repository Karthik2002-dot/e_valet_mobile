class AssignRetrievalResponse {
  final String sessionId;
  final String driverUserId;
  final String status;
  final String assignedAt;
  final String message;

  AssignRetrievalResponse({
    required this.sessionId,
    required this.driverUserId,
    required this.status,
    required this.assignedAt,
    required this.message,
  });

  factory AssignRetrievalResponse.fromJson(Map<String, dynamic> json) {
    return AssignRetrievalResponse(
      sessionId: json['sessionId'] as String,
      driverUserId: json['driverUserId'] as String,
      status: json['status'] as String,
      assignedAt: json['assignedAt'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'driverUserId': driverUserId,
      'status': status,
      'assignedAt': assignedAt,
      'message': message,
    };
  }
}
