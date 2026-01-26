class AssignedTo {
  final String userId;
  final String name;
  final String phone;

  AssignedTo({
    required this.userId,
    required this.name,
    required this.phone,
  });

  factory AssignedTo.fromJson(Map<String, dynamic> json) {
    return AssignedTo(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
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
