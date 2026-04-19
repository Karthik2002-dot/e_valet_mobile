/// GET /api/v1/operators/card-assignments response.
class CardAssignmentsResponse {
  final List<CardAssignment> assignments;

  const CardAssignmentsResponse({required this.assignments});

  factory CardAssignmentsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['assignments'];
    final list = raw is List<dynamic>
        ? raw
            .map((e) =>
                CardAssignment.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <CardAssignment>[];
    return CardAssignmentsResponse(assignments: list);
  }
}

class CardAssignment {
  final int assignmentId;
  final int cardId;
  final int cardNumber;
  final String driverUserId;
  final String driverName;
  final String assignedByUserId;
  final String assignedAt;

  const CardAssignment({
    required this.assignmentId,
    required this.cardId,
    required this.cardNumber,
    required this.driverUserId,
    required this.driverName,
    required this.assignedByUserId,
    required this.assignedAt,
  });

  factory CardAssignment.fromJson(Map<String, dynamic> json) {
    return CardAssignment(
      assignmentId: (json['assignmentId'] as num?)?.toInt() ?? 0,
      cardId: (json['cardId'] as num?)?.toInt() ?? 0,
      cardNumber: (json['cardNumber'] as num?)?.toInt() ?? 0,
      driverUserId: json['driverUserId']?.toString() ?? '',
      driverName: json['driverName']?.toString() ?? '',
      assignedByUserId: json['assignedByUserId']?.toString() ?? '',
      assignedAt: json['assignedAt']?.toString() ?? '',
    );
  }
}

/// Groups API rows by driver; each driver's card numbers sorted unique.
Map<String, List<int>> cardNumbersByDriverFromAssignments(
  List<CardAssignment> assignments,
) {
  final map = <String, List<int>>{};
  for (final a in assignments) {
    if (a.driverUserId.isEmpty) continue;
    map.putIfAbsent(a.driverUserId, () => []).add(a.cardNumber);
  }
  for (final id in map.keys.toList()) {
    final nums = map[id]!.toSet().toList()..sort();
    map[id] = nums;
  }
  return map;
}
