class ValetResponse {
  final String userId;
  final String name;
  final String phone;
  final String status;
  final int carsPickedUp;
  final int carsHandedOver;
  final int onBreakDurationMinutes;
  final String clockInAt;
  final String clockOutAt;
  final String lastActivity;

  ValetResponse({
    required this.userId,
    required this.name,
    required this.phone,
    required this.status,
    required this.carsPickedUp,
    required this.carsHandedOver,
    required this.onBreakDurationMinutes,
    required this.clockInAt,
    required this.clockOutAt,
    required this.lastActivity,
  });

  factory ValetResponse.fromJson(Map<String, dynamic> json) {
    return ValetResponse(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
      carsPickedUp: json['carsPickedUp'] ?? 0,
      carsHandedOver: json['carsHandedOver'] ?? 0,
      onBreakDurationMinutes: json['onBreakDurationMinutes'] ?? 0,
      clockInAt: json['clockInAt'] ?? '',
      clockOutAt: json['clockOutAt'] ?? '',
      lastActivity: json['lastActivity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'status': status,
      'carsPickedUp': carsPickedUp,
      'carsHandedOver': carsHandedOver,
      'onBreakDurationMinutes': onBreakDurationMinutes,
      'clockInAt': clockInAt,
      'clockOutAt': clockOutAt,
      'lastActivity': lastActivity,
    };
  }
}
