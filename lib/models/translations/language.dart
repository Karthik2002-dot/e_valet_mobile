import 'dart:convert';

class Language {
  final int id;
  final String code;
  final String name;
  final String nativeName;
  final bool isActive;
  final bool isDefault;

  Language({
    required this.id,
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isActive,
    required this.isDefault,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: _parseInt(json['id']),
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      nativeName: (json['nativeName'] as String?) ?? '',
      isActive: json['isActive'] == true,
      isDefault: json['isDefault'] == true,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'isActive': isActive,
      'isDefault': isDefault,
    };
  }

  static List<Language> fromJsonList(String jsonString) {
    final decoded = json.decode(jsonString);
    if (decoded is! List) return [];
    return decoded
        .where((e) => e is Map)
        .map((e) => Language.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
