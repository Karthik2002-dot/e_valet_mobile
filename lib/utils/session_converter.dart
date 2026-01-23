import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/models/driver/session/pending_session.dart';

/// Utility class to convert PendingSession to AssignedSession
/// This is used when navigating to screens that require AssignedSession
class SessionConverter {
  SessionConverter._();

  /// Convert a PendingSession to AssignedSession
  /// Uses default/empty values for fields not available in PendingSession
  static AssignedSession pendingToAssigned(PendingSession pendingSession) {
    // Create a status map from the status string
    final statusMap = <String, dynamic>{
      'status': pendingSession.status,
    };

    return AssignedSession(
      id: pendingSession.sessionId,
      cardNumber: pendingSession.cardNumber,
      status: statusMap,
      outletName: '', // Not available in pending session
      assignedAt: pendingSession.assignedAt ?? pendingSession.createdAt,
      customerPhone: pendingSession.customerPhone ?? '',
      parkedBy: null, // Not available in pending session
      photos: const [], // Not available in pending session
      parkingLocation: pendingSession.parkingLocation ?? '',
    );
  }
}

