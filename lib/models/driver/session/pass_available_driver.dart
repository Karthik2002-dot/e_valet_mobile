import 'package:equatable/equatable.dart';

class PassAvailableDriver extends Equatable {
  final String userId;
  final String name;
  final String phone;

  const PassAvailableDriver({
    required this.userId,
    required this.name,
    required this.phone,
  });

  factory PassAvailableDriver.fromJson(Map<String, dynamic> json) {
    return PassAvailableDriver(
      userId: (json['userId'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown Driver').toString(),
      phone: (json['phone'] ?? 'N/A').toString(),
    );
  }

  /// Two initials for the avatar (e.g. "John Driver" → "JD")
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [userId, name, phone];
}
