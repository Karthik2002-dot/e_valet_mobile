class ResetPasswordRequest {
  final String resetToken;
  final String newPassword;

  const ResetPasswordRequest({
    required this.resetToken,
    required this.newPassword,
  });

  Map<String, String> toJson() {
    return {
      'resetToken': resetToken,
      'newPassword': newPassword,
    };
  }
}
