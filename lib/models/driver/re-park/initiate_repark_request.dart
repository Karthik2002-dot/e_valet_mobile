class InitiateReparkRequest {
  final double latitude;
  final double longitude;
  final double accuracy;

  const InitiateReparkRequest({
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

  @override
  String toString() {
    return 'InitiateReparkRequest(latitude: $latitude, longitude: $longitude, accuracy: $accuracy)';
  }
}
