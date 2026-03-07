/// Response for GET /api/v1/operators/settings/auto-assign
class AutoAssignSettingsResponse {
  final int outletId;
  final bool autoAssignEnabled;
  final String message;

  AutoAssignSettingsResponse({
    required this.outletId,
    required this.autoAssignEnabled,
    required this.message,
  });

  factory AutoAssignSettingsResponse.fromJson(Map<String, dynamic> json) {
    return AutoAssignSettingsResponse(
      outletId: json['outletId'] as int? ?? 0,
      autoAssignEnabled: json['autoAssignEnabled'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}
