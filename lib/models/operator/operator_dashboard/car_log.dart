class CarLog {
  final String sessionId;
  final int tagNumber;
  final String duration;
  final String parkedAt;
  final String handoveredAt;
  final String displayStatus;
  final ParkedBy parkedBy;
  final HandoveredBy handoveredBy;
  final String parkingLocation;

  CarLog({
    required this.sessionId,
    required this.tagNumber,
    required this.duration,
    required this.parkedAt,
    required this.handoveredAt,
    required this.displayStatus,
    required this.parkedBy,
    required this.handoveredBy,
    required this.parkingLocation,
  });

  factory CarLog.fromJson(Map<String, dynamic> json) {
    return CarLog(
      sessionId: json['sessionId'] as String? ?? '',
      tagNumber: (json['tagNumber'] as num?)?.toInt() ?? 0,
      duration: json['duration'] as String? ?? '',
      parkedAt: json['parkedAt'] as String? ?? '',
      handoveredAt: json['handoveredAt'] as String? ?? '',
      displayStatus: json['displayStatus'] as String? ?? '',
      parkedBy: ParkedBy.fromJson(json['parkedBy'] as Map<String, dynamic>? ?? {}),
      handoveredBy: HandoveredBy.fromJson(json['handoveredBy'] as Map<String, dynamic>? ?? {}),
      parkingLocation: json['parkingLocation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'tagNumber': tagNumber,
      'duration': duration,
      'parkedAt': parkedAt,
      'handoveredAt': handoveredAt,
      'displayStatus': displayStatus,
      'parkedBy': parkedBy.toJson(),
      'handoveredBy': handoveredBy.toJson(),
      'parkingLocation': parkingLocation,
    };
  }
}

class ParkedBy {
  final String userId;
  final String name;
  final String phone;

  ParkedBy({
    required this.userId,
    required this.name,
    required this.phone,
  });

  factory ParkedBy.fromJson(Map<String, dynamic> json) {
    return ParkedBy(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
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

class HandoveredBy {
  final String userId;
  final String name;

  HandoveredBy({
    required this.userId,
    required this.name,
  });

  factory HandoveredBy.fromJson(Map<String, dynamic> json) {
    return HandoveredBy(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
    };
  }
}
