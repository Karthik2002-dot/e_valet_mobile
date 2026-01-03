class OperatorAvailableDriversResponse {
  final List<AvailableDriver> drivers;

  OperatorAvailableDriversResponse({
    required this.drivers,
  });

  factory OperatorAvailableDriversResponse.fromJson(Map<String, dynamic> json) {
    return OperatorAvailableDriversResponse(
      drivers: (json['drivers'] as List<dynamic>?)
              ?.map((driver) => AvailableDriver.fromJson(driver as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drivers': drivers.map((driver) => driver.toJson()).toList(),
    };
  }
}

class AvailableDriver {
  final String userId;
  final String name;
  final String phone;
  final String status;
  final int currentAssignments;
  final String lastActivity;

  AvailableDriver({
    required this.userId,
    required this.name,
    required this.phone,
    required this.status,
    required this.currentAssignments,
    required this.lastActivity,
  });

  factory AvailableDriver.fromJson(Map<String, dynamic> json) {
    return AvailableDriver(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: json['status'] as String? ?? '',
      currentAssignments: json['currentAssignments'] as int? ?? 0,
      lastActivity: json['lastActivity'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'status': status,
      'currentAssignments': currentAssignments,
      'lastActivity': lastActivity,
    };
  }
}
