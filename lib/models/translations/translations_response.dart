import 'dart:convert';

class TranslationsResponse {
  final String language;
  final Map<String, String> translations;

  TranslationsResponse({
    required this.language,
    required this.translations,
  });

  factory TranslationsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['translations'];
    final Map<String, String> map = {};
    if (raw is Map) {
      for (final e in raw.entries) {
        if (e.value != null) {
          map[e.key.toString()] = e.value.toString();
        }
      }
    }
    return TranslationsResponse(
      language: json['language'] as String? ?? '',
      translations: map,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'translations': translations,
    };
  }

  /// Full response as JSON string for storing in Hive.
  String toJsonString() => json.encode(toJson());

  static TranslationsResponse? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      return TranslationsResponse.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
