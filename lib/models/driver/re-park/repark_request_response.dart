/// Response model for re-park request API
class ReparkRequestResponse {
  final bool success;
  final String message;
  final String? requestId;
  final DateTime? createdAt;
  final Map<String, dynamic>? additionalData;

  const ReparkRequestResponse({
    required this.success,
    required this.message,
    this.requestId,
    this.createdAt,
    this.additionalData,
  });

  factory ReparkRequestResponse.fromJson(Map<String, dynamic> json) {
    return ReparkRequestResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      requestId: json['requestId'] ?? json['id'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      additionalData: json,
    );
  }

  @override
  String toString() {
    return 'ReparkRequestResponse(success: $success, message: $message, requestId: $requestId, createdAt: $createdAt)';
  }
}
