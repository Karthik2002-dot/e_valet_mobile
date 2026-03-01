class ValetLogoutResponse {
  final String? message;

  ValetLogoutResponse({this.message});

  factory ValetLogoutResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ValetLogoutResponse();
    return ValetLogoutResponse(
      message: json['message'] as String?,
    );
  }
}
