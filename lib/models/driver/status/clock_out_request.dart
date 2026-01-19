class ClockOutRequest {
  final double latitude;
  final double longitude;
  final double accuracy;

  ClockOutRequest({
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
