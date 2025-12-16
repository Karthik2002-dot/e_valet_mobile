class PhonePasswordLoginRequest {
  final String phoneNumber;
  final String password;
  final String loginType;

  PhonePasswordLoginRequest({
    required this.phoneNumber,
    required this.password,
    this.loginType = 'PHONE_PASSWORD',
  });

  Map<String, dynamic> toJson() {
    return {
      'loginType': loginType,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}
