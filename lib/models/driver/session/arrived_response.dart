class ArrivedResponse {
  final String sessionId;
  final Map<String, dynamic> status;
  final int cardNumber;
  final String arrivedAt;
  final String message;

  ArrivedResponse({
    required this.sessionId,
    required this.status,
    required this.cardNumber,
    required this.arrivedAt,
    required this.message,
  });

  factory ArrivedResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    Map<String, dynamic> statusMap;
    
    if (rawStatus is Map<String, dynamic>) {
      statusMap = rawStatus;
    } else if (rawStatus is String) {
      statusMap = {'status': rawStatus};
    } else {
      statusMap = {};
    }

    return ArrivedResponse(
      sessionId: (json['sessionId'] ?? '').toString(),
      status: statusMap,
      cardNumber: json['cardNumber'] as int? ?? 0,
      arrivedAt: (json['arrivedAt'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}

