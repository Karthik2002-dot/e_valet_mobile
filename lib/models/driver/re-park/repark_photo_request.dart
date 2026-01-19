/// Model for re-park request
/// Supports two scenarios:
/// 1. With photo: photo + longitude + latitude + accuracy (no parkingLocation)
/// 2. Without photo: parkingLocation + longitude + latitude + accuracy (no photo)
class ReparkPhotoRequest {
  final String? imagePath;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? parkingLocation;

  const ReparkPhotoRequest({
    this.imagePath,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.parkingLocation,
  }) : assert(
          imagePath != null || parkingLocation != null,
          'Either imagePath or parkingLocation must be provided',
        );

  /// Check if photo is provided
  bool get hasPhoto => imagePath != null && imagePath!.isNotEmpty;

  /// Get the filename from the image path
  String? get filename => imagePath?.split('/').last;

  /// Check if parking location is provided
  bool get hasParkingLocation =>
      parkingLocation != null && parkingLocation!.isNotEmpty;

  @override
  String toString() {
    return 'ReparkPhotoRequest(imagePath: $imagePath, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, parkingLocation: $parkingLocation)';
  }
}
