class ImageValidationResult {
  final bool isValid;
  final bool hasVehicle;
  final bool hasNumberPlate;
  final String? detectedText;
  final String? errorMessage;

  ImageValidationResult({
    required this.isValid,
    required this.hasVehicle,
    required this.hasNumberPlate,
    this.detectedText,
    this.errorMessage,
  });

  factory ImageValidationResult.success({
    String? detectedText,
  }) {
    return ImageValidationResult(
      isValid: true,
      hasVehicle: true,
      hasNumberPlate: true,
      detectedText: detectedText,
    );
  }

  factory ImageValidationResult.failure({
    required bool hasVehicle,
    required bool hasNumberPlate,
    required String errorMessage,
  }) {
    return ImageValidationResult(
      isValid: false,
      hasVehicle: hasVehicle,
      hasNumberPlate: hasNumberPlate,
      errorMessage: errorMessage,
    );
  }
}
