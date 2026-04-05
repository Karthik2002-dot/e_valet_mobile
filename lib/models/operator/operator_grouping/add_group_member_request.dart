class AddGroupMemberRequest {
  final String driverUserId;

  AddGroupMemberRequest({required this.driverUserId});

  Map<String, dynamic> toJson() {
    return {
      'driverUserId': driverUserId,
    };
  }
}
