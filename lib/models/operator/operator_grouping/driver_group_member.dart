class DriverGroupMember {
  final String driverUserId;
  final String name;
  final String phone;
  final String joinedAt;

  DriverGroupMember({
    required this.driverUserId,
    required this.name,
    required this.phone,
    required this.joinedAt,
  });

  factory DriverGroupMember.fromJson(Map<String, dynamic> json) {
    return DriverGroupMember(
      driverUserId: (json['driverUserId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      joinedAt: (json['joinedAt'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverUserId': driverUserId,
      'name': name,
      'phone': phone,
      'joinedAt': joinedAt,
    };
  }
}
