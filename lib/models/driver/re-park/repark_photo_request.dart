/// Model for re-park photo upload request
class ReparkPhotoRequest {
  final String imagePath;
  final String? description;

  const ReparkPhotoRequest({
    required this.imagePath,
    this.description,
  });

  /// Get the filename from the image path
  String get filename => imagePath.split('/').last;

  /// Check if description is provided and not empty
  bool get hasDescription => description != null && description!.isNotEmpty;

  @override
  String toString() {
    return 'ReparkPhotoRequest(imagePath: $imagePath, description: $description, filename: $filename)';
  }
}
