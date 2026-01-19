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
    final Map<String, dynamic> data = {
      'cardNumber': cardNumber,
    };
    if (customerPhone != null && customerPhone!.isNotEmpty) {
      data['customerPhone'] = customerPhone;
    }
    if (notes != null && notes!.isNotEmpty) {
      data['notes'] = notes;
    }
    return data;
  }
}
