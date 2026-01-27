import 'pending_session.dart';

class PendingSessionsResponse {
  final List<PendingSession> sessions;
  final int count;
  final int parkingTasksCount;
  final int retrievalTasksCount;
  final bool hasPendingTasks;
  final String message;

  PendingSessionsResponse({
    required this.sessions,
    required this.count,
    required this.parkingTasksCount,
    required this.retrievalTasksCount,
    required this.hasPendingTasks,
    required this.message,
  });

  factory PendingSessionsResponse.fromJson(Map<String, dynamic> json) {
    final sessionsList = json['sessions'] as List? ?? [];
    return PendingSessionsResponse(
      sessions: sessionsList
          .whereType<Map<String, dynamic>>()
          .map((sessionJson) => PendingSession.fromJson(sessionJson))
          .toList(),
      count: json['count'] as int? ?? 0,
      parkingTasksCount: json['parkingTasksCount'] as int? ?? 0,
      retrievalTasksCount: json['retrievalTasksCount'] as int? ?? 0,
      hasPendingTasks: json['hasPendingTasks'] as bool? ?? false,
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'count': count,
      'parkingTasksCount': parkingTasksCount,
      'retrievalTasksCount': retrievalTasksCount,
      'hasPendingTasks': hasPendingTasks,
      'message': message,
    };
  }

  /// Check if there's any session with CHECKED_IN status
  bool get hasCheckedInSession =>
      sessions.any((session) => session.isCheckedIn);

  /// Get the first CHECKED_IN session if any
  PendingSession? get checkedInSession {
    try {
      return sessions.firstWhere((session) => session.isCheckedIn);
    } catch (_) {
      return null;
    }
  }

  /// Check if there's any session with ACCEPT status
  bool get hasAcceptedSession => sessions.any((session) => session.isAccepted);

  /// Get the first ACCEPT session if any
  PendingSession? get acceptedSession {
    try {
      return sessions.firstWhere((session) => session.isAccepted);
    } catch (_) {
      return null;
    }
  }

  /// Check if there's any session with ARRIVED status
  bool get hasArrivedSession => sessions.any((session) => session.isArrived);

  /// Get the first ARRIVED session if any
  PendingSession? get arrivedSession {
    try {
      return sessions.firstWhere((session) => session.isArrived);
    } catch (_) {
      return null;
    }
  }
}
