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
