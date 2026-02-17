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
      id: json['id'],
      code: json['code'],
      name: json['name'],
      nativeName: json['nativeName'],
      isActive: json['isActive'],
      isDefault: json['isDefault'],
    );
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
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.map((e) => Language.fromJson(e)).toList();
  }
}
