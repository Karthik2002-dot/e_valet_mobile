class CheckinRequest {
  final int outletId;
  final int cardNumber;
  final bool isManualEntry;

  CheckinRequest({
    required this.outletId,
    required this.cardNumber,
    required this.isManualEntry,
  });

  Map<String, dynamic> toJson() {
    return {
      'outletId': outletId,
      'cardNumber': cardNumber,
      'isManualEntry': isManualEntry,
    };
  }
}

