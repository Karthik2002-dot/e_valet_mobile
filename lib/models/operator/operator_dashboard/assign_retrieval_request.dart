class AssignRetrievalRequest {
  final String sessionId;
  final String driverUserId;

  AssignRetrievalRequest({
    required this.sessionId,
    required this.driverUserId,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'driverUserId': driverUserId,
    };
  }
}
