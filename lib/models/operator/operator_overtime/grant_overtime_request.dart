class GrantOvertimeRequest {
  final String driverUserId;
  final int outletId;
  final int extraMinutes;
  final String reason;

  GrantOvertimeRequest({
    required this.driverUserId,
    required this.outletId,
    required this.extraMinutes,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'driverUserId': driverUserId,
      'outletId': outletId,
      'extraMinutes': extraMinutes,
      'reason': reason,
    };
  }
}
