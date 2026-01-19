class HandoverResponse {
  final String sessionId;
  final Map<String, dynamic> status;
  final int cardNumber;
  final String completedAt;
  final String message;

  HandoverResponse({
    required this.sessionId,
    required this.status,
    required this.cardNumber,
    required this.completedAt,
    required this.message,
  });

  factory HandoverResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    Map<String, dynamic> statusMap;

    if (rawStatus is Map<String, dynamic>) {
      statusMap = rawStatus;
    } else if (rawStatus is String) {
      statusMap = {'status': rawStatus};
    } else {
      statusMap = {};
    }

    return HandoverResponse(
      sessionId: (json['sessionId'] ?? '').toString(),
      status: statusMap,
      cardNumber: json['cardNumber'] as int? ?? 0,
      completedAt: (json['completedAt'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}
