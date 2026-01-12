class FcmRegisterRequest {
  final String deviceId;
  final String fcmToken;
  final String platform;
  final String appVersion;
  final String osVersion;

  FcmRegisterRequest({
    required this.deviceId,
    required this.fcmToken,
    required this.platform,
    required this.appVersion,
    required this.osVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'fcmToken': fcmToken,
      'platform': platform,
      'appVersion': appVersion,
      'osVersion': osVersion,
    };
  }

  factory FcmRegisterRequest.fromJson(Map<String, dynamic> json) {
    return FcmRegisterRequest(
      deviceId: json['deviceId'],
      fcmToken: json['fcmToken'],
      platform: json['platform'],
      appVersion: json['appVersion'],
      osVersion: json['osVersion'],
    );
  }
}
