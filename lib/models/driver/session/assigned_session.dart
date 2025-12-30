class AssignedSession {
  final String sessionId;
  final int cardNumber;
  final Map<String, dynamic> status;
  final String outletName;
  final String assignedAt;
  final String customerPhone;
  final AssignedSessionParkedBy? parkedBy;
  final List<AssignedSessionPhoto> photos;

  AssignedSession({
    required this.sessionId,
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
      sessionId: (json['sessionId'] ?? '').toString(),
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

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
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

class AssignedSessionParkedBy {
  final String userId;
  final String name;
  final String phone;

  AssignedSessionParkedBy({
    required this.userId,
    required this.name,
    required this.phone,
  });

  factory AssignedSessionParkedBy.fromJson(Map<String, dynamic> json) {
    return AssignedSessionParkedBy(
      userId: (json['userId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
    };
  }
}

class AssignedSessionPhoto {
  final int id;
  final String url;
  final String description;
  final DateTime? takenAt;

  AssignedSessionPhoto({
    required this.id,
    required this.url,
    required this.description,
    required this.takenAt,
  });

  factory AssignedSessionPhoto.fromJson(Map<String, dynamic> json) {
    final takenAtRaw = json['takenAt'];
    DateTime? parsedTakenAt;
    if (takenAtRaw is String && takenAtRaw.isNotEmpty) {
      parsedTakenAt = DateTime.tryParse(takenAtRaw);
    }

    return AssignedSessionPhoto(
      id: json['id'] as int? ?? 0,
      url: (json['url'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      takenAt: parsedTakenAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'description': description,
      'takenAt': takenAt?.toIso8601String(),
    };
  }
}
