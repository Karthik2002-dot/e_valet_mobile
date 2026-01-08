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

  AssignedSession({
    required this.id,
    required this.cardNumber,
    required this.status,
    required this.outletName,
    required this.assignedAt,
    required this.customerPhone,
    required this.parkedBy,
    required this.photos,
  });

  factory AssignedSession.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    return AssignedSession(
      id: (json['sessionId'] ?? json['id'] ?? '').toString(),
      cardNumber: json['cardNumber'] as int? ?? 0,
      status: (rawStatus is Map<String, dynamic>) ? rawStatus : const {},
      outletName: (json['outletName'] ?? '').toString(),
      assignedAt: (json['assignedAt'] ?? '').toString(),
      customerPhone: (json['customerPhone'] ?? '').toString(),
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
    };
  }
}
