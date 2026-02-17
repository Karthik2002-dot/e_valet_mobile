class ParkedBy {
  final String? userId;
  final String name;
  final String? phone;

  ParkedBy({
    this.userId,
    required this.name,
    this.phone,
  });

  factory ParkedBy.fromJson(Map<String, dynamic> json) {
    return ParkedBy(
      userId: json['userId'] as String?,
      name: json['name'] ?? 'Unknown',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'name': name,
      if (phone != null) 'phone': phone,
    };
  }
}
