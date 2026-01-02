class AcceptResponse {
  final String sessionId;
  final Map<String, dynamic> status;
  final int cardNumber;
  final String acceptedAt;
  final String message;

  AcceptResponse({
    required this.sessionId,
    required this.status,
    required this.cardNumber,
    required this.acceptedAt,
    required this.message,
  });

  factory AcceptResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    Map<String, dynamic> statusMap;

    if (rawStatus is Map<String, dynamic>) {
      statusMap = rawStatus;
    } else if (rawStatus is String) {
      statusMap = {'status': rawStatus};
    } else {
      statusMap = {};
    }

    return AcceptResponse(
      sessionId: (json['sessionId'] ?? '').toString(),
      status: statusMap,
      cardNumber: json['cardNumber'] as int? ?? 0,
      acceptedAt: (json['acceptedAt'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}
