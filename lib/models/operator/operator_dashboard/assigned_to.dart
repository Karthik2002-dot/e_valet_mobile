class AssignedTo {
  final String userId;
  final String name;

  AssignedTo({
    required this.userId,
    required this.name,
  });

  factory AssignedTo.fromJson(Map<String, dynamic> json) {
    return AssignedTo(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
    };
  }
}
