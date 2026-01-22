class KeyRackItem {
  final int cardNumber;
  final String sessionId;
  final String photoUrl;
  final String parkedAt;
  final String duration;
  final String? parkingLocation;
  final String? parkedByName;

  KeyRackItem({
    required this.cardNumber,
    required this.sessionId,
    required this.photoUrl,
    required this.parkedAt,
    required this.duration,
    this.parkingLocation,
    this.parkedByName,
  });

  factory KeyRackItem.fromJson(Map<String, dynamic> json) {
    // Extract parkedBy name
    String? parkedByName;
    if (json['parkedBy'] != null && json['parkedBy'] is Map) {
      parkedByName = json['parkedBy']['name'] as String?;
    }

    return KeyRackItem(
      cardNumber: json['cardNumber'] ?? 0,
      sessionId: json['sessionId'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      parkedAt: json['parkedAt'] ?? '',
      duration: json['duration'] ?? '',
      parkingLocation: json['parkingLocation'],
      parkedByName: parkedByName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'sessionId': sessionId,
      'photoUrl': photoUrl,
      'parkedAt': parkedAt,
      'duration': duration,
      'parkingLocation': parkingLocation,
      'parkedByName': parkedByName,
    };
  }
}
