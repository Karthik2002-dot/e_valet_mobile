/// Model for re-park request
class ReparkRequest {
  final String reason;
  final String notes;

  const ReparkRequest({
    required this.reason,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'notes': notes,
    };
  }

  factory ReparkRequest.customerNoShow({String notes = ''}) {
    return ReparkRequest(
      reason: 'CUSTOMER_NO_SHOW',
      notes: notes,
    );
  }

  @override
  String toString() {
    return 'ReparkRequest(reason: $reason, notes: $notes)';
  }
}
