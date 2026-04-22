class CheckinRequest {
  final int outletId;
  final int cardNumber;
  CheckinRequest({
    required this.outletId,
    required this.cardNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'outletId': outletId,
      'cardNumber': cardNumber,
    };
  }
}
