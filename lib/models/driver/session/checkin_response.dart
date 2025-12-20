class CheckinResponse {
  final String sessionId;
  final String status;
  final int cardNumber;
  final int outletId;
  final DateTime? firstCheckinAt;
  final String message;

  CheckinResponse({
    required this.sessionId,
    required this.status,
    required this.cardNumber,
    required this.outletId,
    this.firstCheckinAt,
    required this.message,
  });

  factory CheckinResponse.fromJson(Map<String, dynamic> json) {
    return CheckinResponse(
      sessionId: (json['sessionId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      cardNumber: json['cardNumber'] as int? ?? 0,
      outletId: json['outletId'] as int? ?? 0,
      firstCheckinAt: json['firstCheckinAt'] != null
          ? DateTime.parse(json['firstCheckinAt'] as String)
          : null,
      message: (json['message'] ?? '').toString(),
    );
  }
}
