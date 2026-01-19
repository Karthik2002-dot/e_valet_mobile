class BreakStartRequest {
  final double latitude;
  final double longitude;
  final double accuracy;

  BreakStartRequest({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
    };
  }
}
