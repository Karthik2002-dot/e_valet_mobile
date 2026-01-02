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
