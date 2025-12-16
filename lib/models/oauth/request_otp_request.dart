class RequestOtpRequest {
  final String identifier;
  final String purpose;

  const RequestOtpRequest({
    required this.identifier,
    required this.purpose,
  });

  Map<String, String> toJson() {
    return {
      'identifier': identifier,
      'purpose': purpose,
    };
  }
}
