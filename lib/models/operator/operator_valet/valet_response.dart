class ValetResponse {
  final String userId;
  final String name;
  final String phone;
  final String status;
  final int carsPickedUp;
  final int carsHandedOver;
  final int onBreakDurationMinutes;
  final String clockInAt;
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
      'lastActivity': lastActivity,
    };
  }
}

class ValetListResponse {
  final List<ValetResponse> valets;
  final int total;

  ValetListResponse({
    required this.valets,
    required this.total,
  });

  factory ValetListResponse.fromJson(Map<String, dynamic> json) {
    return ValetListResponse(
      valets: (json['valets'] as List<dynamic>?)
              ?.map((item) => ValetResponse.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valets': valets.map((valet) => valet.toJson()).toList(),
      'total': total,
    };
  }
}
