class VerifyLocationResponse {
  final int outletId;
  final String outletName;
  final bool withinBounds;
  final double distanceMeters;
  final double allowedRadiusMeters;

  const VerifyLocationResponse({
    required this.outletId,
    required this.outletName,
    required this.withinBounds,
    required this.distanceMeters,
    required this.allowedRadiusMeters,
  });

  factory VerifyLocationResponse.fromJson(Map<String, dynamic> json) {
    return VerifyLocationResponse(
      outletId: json['outletId'] as int,
      outletName: json['outletName'] as String,
      withinBounds: json['withinBounds'] as bool,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      allowedRadiusMeters: (json['allowedRadiusMeters'] as num).toDouble(),
    );
  }
}
