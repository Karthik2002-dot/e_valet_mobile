/// Response for GET /operators/assign-retrieval - assignment/retrieval status.
/// Used when driver polls to detect operator status changes in Car Logs.
class AssignRetrievalStatusResponse {
  final String sessionId;
  final String status;

  AssignRetrievalStatusResponse({
    required this.sessionId,
    required this.status,
  });

  factory AssignRetrievalStatusResponse.fromJson(Map<String, dynamic> json) {
    final sessionId = (json['sessionId'] ?? json['id'] ?? '').toString();
    final rawStatus = json['status'];
    String status = '';
    if (rawStatus is String) {
      status = rawStatus.trim().toUpperCase();
    } else if (rawStatus is Map && rawStatus.containsKey('status')) {
      status = (rawStatus['status'] ?? '').toString().trim().toUpperCase();
    } else if (rawStatus is Map && rawStatus.containsKey('name')) {
      status = (rawStatus['name'] ?? '').toString().trim().toUpperCase();
    }
    return AssignRetrievalStatusResponse(
      sessionId: sessionId,
      status: status,
    );
  }

  bool get isArrived => status == 'ARRIVED';
  bool get isParked => status == 'PARKED';
  bool get isCompleted =>
      status == 'COMPLETED' || status == 'HANDOVER' || status == 'HANDED_OVER';
  bool get isAccepted => status == 'ACCEPTED' || status == 'ACCEPT';
}
