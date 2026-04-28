class ButtonConfig {
  final int confirmArrivalDisableSeconds;
  final int customerMissingDisableSeconds;
  final int confirmHandoverDisableSeconds;

  const ButtonConfig({
    required this.confirmArrivalDisableSeconds,
    required this.customerMissingDisableSeconds,
    required this.confirmHandoverDisableSeconds,
  });

  factory ButtonConfig.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, int fallback) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return ButtonConfig(
      confirmArrivalDisableSeconds:
          toInt(json['confirmArrivalDisableSeconds'], 10),
      customerMissingDisableSeconds:
          toInt(json['customerMissingDisableSeconds'], 60),
      confirmHandoverDisableSeconds:
          toInt(json['confirmHandoverDisableSeconds'], 10),
    );
  }
}
