import 'package:hive/hive.dart';
import 'package:niloufer_valet_mobile/api/translations/translations_api_service.dart';
import 'package:niloufer_valet_mobile/models/translations/translations_response.dart';
import 'package:niloufer_valet_mobile/services/translations/language_cache.dart';

class TranslationsCache {
  static const String _boxName = 'translationsBox';
  static const String _selectedLanguageCodeKey = 'selected_language_code';
  static const String _translationsJsonKey = 'translations_json';

  Future<Box> _openBox() => Hive.openBox(_boxName);

  /// Returns the currently selected language code, or null if never set.
  Future<String?> getSelectedLanguageCode() async {
    final box = await _openBox();
    return box.get(_selectedLanguageCodeKey) as String?;
  }

  /// Clears existing translation data, fetches for [languageCode], and stores
  /// the full response JSON in Hive together with the selected code.
  Future<void> setSelectedLanguageAndFetch(String languageCode) async {
    final box = await _openBox();
    box.delete(_translationsJsonKey);
    box.delete(_selectedLanguageCodeKey);

    final response =
        await TranslationsApiService.fetchTranslations(languageCode);
    await box.put(_translationsJsonKey, response.toJsonString());
    await box.put(_selectedLanguageCodeKey, languageCode);
  }

  /// Returns the cached translations for the current language, or null.
  Future<TranslationsResponse?> getTranslations() async {
    final box = await _openBox();
    final jsonString = box.get(_translationsJsonKey) as String?;
    return TranslationsResponse.fromJsonString(jsonString);
  }

  /// Call on app open (and effectively on install): ensure we have a selected
  /// language and fresh translations in Hive. If no language is selected yet,
  /// uses the default from the language list and fetches. Otherwise fetches
  /// translations for the selected language and updates Hive.
  Future<void> ensureTranslationsLoaded() async {
    String? code = await getSelectedLanguageCode();
    if (code == null || code.isEmpty) {
      final languages = await LanguageCache().getLanguages();
      if (languages.isEmpty) return;
      final defaultLang = languages.firstWhere((l) => l.isDefault,
          orElse: () => languages.first);
      code = defaultLang.code;
      await setSelectedLanguageAndFetch(code);
      return;
    }
    // Refresh translations for current language
    try {
      final response = await TranslationsApiService.fetchTranslations(code);
      final box = await _openBox();
      await box.put(_translationsJsonKey, response.toJsonString());
    } catch (_) {
      // Keep existing cache on network failure
    }
  }
}
