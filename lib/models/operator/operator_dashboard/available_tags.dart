class AvailableTags {
  final int available;
  final int total;

  AvailableTags({
    required this.available,
    required this.total,
  });

  factory AvailableTags.fromJson(Map<String, dynamic> json) {
    return AvailableTags(
      available: json['available'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'total': total,
    };
  }
}
