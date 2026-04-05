class Outlet {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int allowedClockInRadiusMeters;

  const Outlet({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.allowedClockInRadiusMeters,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      allowedClockInRadiusMeters:
          (json['allowedClockInRadiusMeters'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'allowedClockInRadiusMeters': allowedClockInRadiusMeters,
    };
  }
}
