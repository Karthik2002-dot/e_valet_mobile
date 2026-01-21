class CheckinRequest {
  final int outletId;
  final int cardNumber;
  final bool isManualRequest;

  CheckinRequest({
    required this.outletId,
    required this.cardNumber,
    required this.isManualRequest,
  });

  Map<String, dynamic> toJson() {
    return {
      'outletId': outletId,
      'cardNumber': cardNumber,
      'isManualRequest': isManualRequest,
    };
  }
}
