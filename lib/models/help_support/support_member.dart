/// Model for support member from GET /api/support-members
class SupportMember {
  final int id;
  final String name;
  final String phoneNumber;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  SupportMember({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportMember.fromJson(Map<String, dynamic> json) {
    return SupportMember(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
