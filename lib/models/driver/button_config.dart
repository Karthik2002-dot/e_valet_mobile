class ButtonConfig {
  final int confirmArrivalDisableSeconds;
  final int customerMissingDisableSeconds;
  final int confirmHandoverDisableSeconds;
  final bool scannerButtonStatus;
  final int imageCompressionQuality;
  final int imageCompressionMaxSizeKB;

  const ButtonConfig({
    required this.confirmArrivalDisableSeconds,
    required this.customerMissingDisableSeconds,
    required this.confirmHandoverDisableSeconds,
    required this.scannerButtonStatus,
    required this.imageCompressionQuality,
    required this.imageCompressionMaxSizeKB,
  });

  factory ButtonConfig.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, int fallback) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool toBool(dynamic value, bool fallback) {
      if (value is bool) return value;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
      return fallback;
    }

    return ButtonConfig(
      confirmArrivalDisableSeconds:
          toInt(json['confirmArrivalDisableSeconds'], 10),
      customerMissingDisableSeconds:
          toInt(json['customerMissingDisableSeconds'], 60),
      confirmHandoverDisableSeconds:
          toInt(json['confirmHandoverDisableSeconds'], 10),
      scannerButtonStatus: toBool(json['scannerButtonStatus'], false),
      imageCompressionQuality: toInt(json['imageCompressionQuality'], 40),
      imageCompressionMaxSizeKB: toInt(json['imageCompressionMaxSizeKB'], 30),
    );
  }
}
