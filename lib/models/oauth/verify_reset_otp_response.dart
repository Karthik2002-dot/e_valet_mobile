class VerifyResetOtpResponse {
  final String message;
  final String? resetToken;

  const VerifyResetOtpResponse({
    required this.message,
    required this.resetToken,
  });
}
