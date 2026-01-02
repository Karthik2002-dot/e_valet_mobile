
class AvailableValets {
  final int available;
  final int total;

  AvailableValets({
    required this.available,
    required this.total,
  });

  factory AvailableValets.fromJson(Map<String, dynamic> json) {
    return AvailableValets(
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
