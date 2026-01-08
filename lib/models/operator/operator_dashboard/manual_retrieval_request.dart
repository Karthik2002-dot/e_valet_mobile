class ManualRetrievalRequest {
  final int cardNumber;
  final String? customerPhone;
  final String? notes;

  ManualRetrievalRequest({
    required this.cardNumber,
    this.customerPhone,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'customerPhone': customerPhone ?? '',
      'notes': notes ?? '',
    };
  }
}
