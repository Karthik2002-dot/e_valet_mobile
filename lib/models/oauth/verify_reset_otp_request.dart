class VerifyResetOtpRequest {
  final String identifier;
  final String otp;

  const VerifyResetOtpRequest({
    required this.identifier,
    required this.otp,
  });

  Map<String, String> toJson() {
    return {
      'identifier': identifier,
      'otp': otp,
    };
  }
}
