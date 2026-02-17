import 'package:flutter/foundation.dart';
import 'package:niloufer_valet_mobile/services/translations/translations_cache.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

/// Holds the current translation map in memory so the UI can read translated
/// strings synchronously. Call [load] on app start and after the user changes
/// language so the app rebuilds with new translations.
///
/// Usage: pass the [TextConstants] value; the notifier resolves the API key
/// and returns the translated string (or the same value as fallback).
///
///   final t = context.watch<AppTranslationsNotifier>();
///   Text(t.get(TextConstants.logout));
///   title: t.get(TextConstants.dashboard),
class AppTranslationsNotifier extends ChangeNotifier {
  Map<String, String>? _translations;

  /// API key -> default (TextConstants) value.
  static const Map<String, String> _defaults = {
    'dashboard': TextConstants.dashboard,
    'slots': TextConstants.slots,
    'parkedCar': TextConstants.parkedCar,
    'valets': TextConstants.valets,
    'carLogs': TextConstants.carLogs,
    'profile': TextConstants.profile,
    'logout': TextConstants.logout,
  };

  static Map<String, String>? _valueToKey;

  /// Default value -> API key (built from _defaults).
  static Map<String, String> get _valueToKeyMap {
    _valueToKey ??= _defaults.map((k, v) => MapEntry(v, k));
    return _valueToKey!;
  }

  /// Returns the translated string for the text that matches [textConstant]
  /// (e.g. TextConstants.logout). Resolves the API key from the constant value,
  /// then returns the translation or the same text as fallback.
  String get(String textConstant) {
    final apiKey = _valueToKeyMap[textConstant];
    if (apiKey != null) {
      final value = _translations?[apiKey];
      if (value != null && value.isNotEmpty) return value;
      return _defaults[apiKey]!;
    }
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
