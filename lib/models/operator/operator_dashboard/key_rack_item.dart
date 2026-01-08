class KeyRackItem {
  final int cardNumber;
  final String sessionId;
  final String photoUrl;
  final String parkedAt;
  final String duration;
  final String parkedBy;

  KeyRackItem({
    required this.cardNumber,
    required this.sessionId,
    required this.photoUrl,
    required this.parkedAt,
    required this.duration,
    required this.parkedBy,
  });

  factory KeyRackItem.fromJson(Map<String, dynamic> json) {
    return KeyRackItem(
      cardNumber: json['cardNumber'] ?? 0,
      sessionId: json['sessionId'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      parkedAt: json['parkedAt'] ?? '',
      duration: json['duration'] ?? '',
      parkedBy: json['parkedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'sessionId': sessionId,
      'photoUrl': photoUrl,
      'parkedAt': parkedAt,
      'duration': duration,
      'parkedBy': parkedBy,
    };
  }
}
