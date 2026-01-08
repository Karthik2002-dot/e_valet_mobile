/// Response model for re-park photo upload API
class ReparkPhotoResponse {
  final bool success;
  final String message;
  final String? photoUrl;
  final String? photoId;
  final DateTime? uploadedAt;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? additionalData;

  const ReparkPhotoResponse({
    required this.success,
    required this.message,
    this.photoUrl,
    this.photoId,
    this.uploadedAt,
    this.metadata,
    this.additionalData,
  });

  factory ReparkPhotoResponse.fromJson(Map<String, dynamic> json) {
    return ReparkPhotoResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      photoUrl: json['photoUrl'] ?? json['url'] ?? json['imageUrl'],
      photoId: json['photoId'] ?? json['id'] ?? json['imageId'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : null,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      additionalData: json,
    );
  }

  @override
  String toString() {
    return 'ReparkPhotoResponse(success: $success, message: $message, photoUrl: $photoUrl, photoId: $photoId, uploadedAt: $uploadedAt)';
  }
}
