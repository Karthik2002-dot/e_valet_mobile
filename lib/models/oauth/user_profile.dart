class UserProfile {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String fullName;
  final String phoneNumber;
  final bool isActive;
  final String createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phoneNumber,
    required this.isActive,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}