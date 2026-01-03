class ManualRetrievalResponse {
  final String sessionId;
  final int cardNumber;
  final String status;
  final String requestedAt;
  final String message;

  ManualRetrievalResponse({
    required this.sessionId,
    required this.cardNumber,
    required this.status,
    required this.requestedAt,
    required this.message,
  });

  factory ManualRetrievalResponse.fromJson(Map<String, dynamic> json) {
    return ManualRetrievalResponse(
      sessionId: json['sessionId'] as String,
      cardNumber: json['cardNumber'] as int,
      status: json['status'] as String,
      requestedAt: json['requestedAt'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'cardNumber': cardNumber,
      'status': status,
      'requestedAt': requestedAt,
      'message': message,
    };
  }
}
