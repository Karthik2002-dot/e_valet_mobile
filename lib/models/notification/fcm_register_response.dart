class FcmRegisterResponse {
  final bool success;
  final String? message;
  final String? deviceId;

  FcmRegisterResponse({
    required this.success,
    this.message,
    this.deviceId,
  });

  factory FcmRegisterResponse.fromJson(Map<String, dynamic> json) {
    return FcmRegisterResponse(
      success: json['success'] ?? true,
      message: json['message'],
      deviceId: json['deviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'deviceId': deviceId,
    };
  }
}
