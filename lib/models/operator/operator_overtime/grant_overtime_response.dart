class GrantOvertimeResponse {
  final int? id;
  final String? driverUserId;
  final int? outletId;
  final String? grantedByUserId;
  final String? grantedAt;
  final int? extraMinutes;
  final String? expiresAt;
  final String? reason;
  final String? message;

  GrantOvertimeResponse({
    this.id,
    this.driverUserId,
    this.outletId,
    this.grantedByUserId,
    this.grantedAt,
    this.extraMinutes,
    this.expiresAt,
    this.reason,
    this.message,
  });

  factory GrantOvertimeResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrantOvertimeResponse();
    return GrantOvertimeResponse(
      id: json['id'] as int?,
      driverUserId: json['driverUserId'] as String?,
      outletId: json['outletId'] as int?,
      grantedByUserId: json['grantedByUserId'] as String?,
      grantedAt: json['grantedAt'] as String?,
      extraMinutes: json['extraMinutes'] as int?,
      expiresAt: json['expiresAt'] as String?,
      reason: json['reason'] as String?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverUserId': driverUserId,
      'outletId': outletId,
      'grantedByUserId': grantedByUserId,
      'grantedAt': grantedAt,
      'extraMinutes': extraMinutes,
      'expiresAt': expiresAt,
      'reason': reason,
      'message': message,
    };
  }
}
