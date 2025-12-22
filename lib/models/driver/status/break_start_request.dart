class BreakStartRequest {
  final double latitude;
  final double longitude;
  final String address;

  BreakStartRequest({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
