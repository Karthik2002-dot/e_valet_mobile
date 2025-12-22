class QrData {
  final int outletId;
  final int cardNumber;

  QrData({
    required this.outletId,
    required this.cardNumber,
  });

  factory QrData.fromJson(Map<String, dynamic> json) {
    return QrData(
      outletId: json['outletId'] as int? ?? 0,
      cardNumber: json['cardNumber'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'outletId': outletId,
      'cardNumber': cardNumber,
    };
  }
}
