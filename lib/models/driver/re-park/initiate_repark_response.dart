class InitiateReparkResponse {
  final String sessionId;
  final Map<String, dynamic> status;
  final int cardNumber;
  final String initiatedAt;
  final String message;

  const InitiateReparkResponse({
    required this.sessionId,
    required this.status,
    required this.cardNumber,
    required this.initiatedAt,
    required this.message,
  });

  factory InitiateReparkResponse.fromJson(Map<String, dynamic> json) {
    return InitiateReparkResponse(
      sessionId: (json['sessionId'] ?? '').toString(),
      status: json['status'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['status'] as Map)
          : <String, dynamic>{},
      cardNumber: json['cardNumber'] as int? ?? 0,
      initiatedAt: (json['initiatedAt'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'status': status,
      'cardNumber': cardNumber,
      'initiatedAt': initiatedAt,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'InitiateReparkResponse(sessionId: $sessionId, cardNumber: $cardNumber, message: $message)';
  }
}
