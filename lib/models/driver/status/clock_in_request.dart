class ClockInRequest {
  final int outletId;
  final double latitude;
  final double longitude;
  final String address;

  ClockInRequest({
    required this.outletId,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'outletId': outletId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
