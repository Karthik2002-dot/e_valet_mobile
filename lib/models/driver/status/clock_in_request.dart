class ClockInRequest {
  final int outletId;
  final double latitude;
  final double longitude;
  final double accuracy;

  ClockInRequest({
    required this.outletId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'outletId': outletId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
    };
  }
}
