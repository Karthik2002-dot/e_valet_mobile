class ParkedBy {
  final String name;
  final String? phone;

  ParkedBy({
    required this.name,
    this.phone,
  });

  factory ParkedBy.fromJson(Map<String, dynamic> json) {
    return ParkedBy(
      name: json['name'] ?? 'Unknown',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (phone != null) 'phone': phone,
    };
  }
}
