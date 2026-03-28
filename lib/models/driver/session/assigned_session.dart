import 'assigned_session_parked_by.dart';
import 'assigned_session_photo.dart';

class AssignedSession {
  final String id;
  final int cardNumber;
  final Map<String, dynamic> status;
  final String outletName;
  final String assignedAt;
  final String customerPhone;
  final AssignedSessionParkedBy? parkedBy;
  final List<AssignedSessionPhoto> photos;
  final String parkingLocation;

  AssignedSession({
    required this.id,
    required this.cardNumber,
    required this.status,
    required this.outletName,
    required this.assignedAt,
    required this.customerPhone,
    required this.parkedBy,
    required this.photos,
    required this.parkingLocation,
  });

  /// Normalizes API status (map or string) so [retrievalLifecycleStatus] works.
  static Map<String, dynamic> _statusMapFromJson(dynamic rawStatus) {
    if (rawStatus is Map<String, dynamic>) return rawStatus;
    if (rawStatus is String && rawStatus.trim().isNotEmpty) {
      return {'name': rawStatus.trim()};
    }
    return const {};
  }

  factory AssignedSession.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    return AssignedSession(
      id: (json['sessionId'] ?? json['id'] ?? '').toString(),
      cardNumber: json['cardNumber'] as int? ?? 0,
      status: _statusMapFromJson(rawStatus),
      outletName: (json['outletName'] ?? '').toString(),
      assignedAt: (json['assignedAt'] ?? '').toString(),
      customerPhone: (json['customerPhone'] ?? '').toString(),
      parkingLocation: (json['parkingLocation'] ?? '').toString(),
      parkedBy: json['parkedBy'] != null
          ? AssignedSessionParkedBy.fromJson(
              Map<String, dynamic>.from(json['parkedBy'] as Map),
            )
          : null,
      photos: (json['photos'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AssignedSessionPhoto.fromJson)
              .toList() ??
          const [],
    );
  }

  bool get hasPhotos => photos.isNotEmpty;

  String? get photoUrl => photos.isNotEmpty ? photos.first.url : null;

  /// Uppercase lifecycle for retrieval (e.g. ASSIGNED, ACCEPTED). Accept API expects ASSIGNED.
  String get retrievalLifecycleStatus {
    if (status.isEmpty) return '';
    for (final k in ['name', 'value', 'status', 'state', 'code']) {
      final v = status[k];
      if (v is String && v.trim().isNotEmpty) return v.trim().toUpperCase();
    }
    return '';
  }

  /// True when POST accept is valid; false when already past ASSIGNED (caller should skip API).
  bool get canCallAcceptRetrievalApi {
    final s = retrievalLifecycleStatus;
    if (s.isEmpty) return true;
    return s == 'ASSIGNED';
  }

  // Add a field to store pending photo path
  String? pendingPhotoPath;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'status': status,
      'outletName': outletName,
      'assignedAt': assignedAt,
      'customerPhone': customerPhone,
      'parkedBy': parkedBy?.toJson(),
      'photos': photos.map((photo) => photo.toJson()).toList(),
      'parkingLocation': parkingLocation,
    };
  }
}
