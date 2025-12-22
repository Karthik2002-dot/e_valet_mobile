class UpdateDriverStatusRequest {
  final String status; // "ONLINE" or "OFFLINE"
  final double latitude;
  final double longitude;

  UpdateDriverStatusRequest({
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
