import 'package:flutter/foundation.dart';
import 'package:niloufer_valet_mobile/services/translations/translations_cache.dart';

/// Holds the current translation map in memory so the UI can read translated
/// strings synchronously. Call [load] on app start and after the user changes
/// language so the app rebuilds with new translations.
class AppTranslationsNotifier extends ChangeNotifier {
  Map<String, String>? _translations;

  /// Converts a display string (e.g. "Parked Car", "Dashboard") to the API key
  /// format (e.g. "parkedCar", "dashboard") so we can look up in the API response.
  static String _displayStringToApiKey(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return value.toLowerCase();
    final first = parts.first.toLowerCase();
    if (parts.length == 1) return first;
    final rest = parts
        .skip(1)
        .map((p) =>
            p.isEmpty ? p : p[0].toUpperCase() + p.substring(1).toLowerCase())
        .join();
    return first + rest;
  }

  /// Returns the translated string for [textConstant] (e.g. [TextConstants.logout]).
  /// Derives the API key from the string; returns translation or [textConstant] as fallback.
  String get(String textConstant) {
    final apiKey = _displayStringToApiKey(textConstant);
    final value = _translations?[apiKey];
    if (value != null && value.isNotEmpty) return value;
    return textConstant;
  }

  /// Loads translations from [TranslationsCache] and notifies listeners so the
  /// app rebuilds. Call after app start (e.g. in provider create) and after
  /// the user selects a new language in the language dropdown.
  Future<void> load() async {
    try {
      final response = await TranslationsCache().getTranslations();
      _translations = response?.translations;
      notifyListeners();
    } catch (_) {
      // Keep previous translations on error
    }
  }
}
