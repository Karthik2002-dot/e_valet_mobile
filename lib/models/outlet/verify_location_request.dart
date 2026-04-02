class VerifyLocationRequest {
  final double latitude;
  final double longitude;
  final double accuracy;

  const VerifyLocationRequest({
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
