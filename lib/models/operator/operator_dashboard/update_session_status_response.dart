class UpdateSessionStatusResponse {
  final String sessionId;
  final String oldStatus;
  final String newStatus;
  final String updatedAt;
  final String message;

  UpdateSessionStatusResponse({
    required this.sessionId,
    required this.oldStatus,
    required this.newStatus,
    required this.updatedAt,
    required this.message,
  });

  factory UpdateSessionStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateSessionStatusResponse(
      sessionId: json['sessionId'] as String? ?? '',
      oldStatus: json['oldStatus'] as String? ?? '',
      newStatus: json['newStatus'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'updatedAt': updatedAt,
      'message': message,
    };
  }
}
