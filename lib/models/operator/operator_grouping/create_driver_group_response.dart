class CreateDriverGroupResponse {
  final int id;
  final int outletId;
  final String name;
  final int memberCount;
  final String createdAt;
  final String updatedAt;

  CreateDriverGroupResponse({
    required this.id,
    required this.outletId,
    required this.name,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreateDriverGroupResponse.fromJson(Map<String, dynamic> json) {
    return CreateDriverGroupResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      outletId: (json['outletId'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] as String?) ?? '',
      updatedAt: (json['updatedAt'] as String?) ?? '',
    );
  }
}
