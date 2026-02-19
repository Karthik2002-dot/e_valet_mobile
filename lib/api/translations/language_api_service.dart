import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/translations/language.dart';

class LanguageApiService {
  LanguageApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<List<Language>> fetchLanguages() async {
    final base = BaseDioService(
      _baseUrl,
      ApiConfig.defaultJsonHeaders,
    );

    try {
      final response = await base.get('/i18n/languages');

      final data = response.data;
      if (data is! List) {
        throw ApiException(
          'Invalid response format for languages.',
          code: 'invalid_response',
        );
      }

      return data
          .map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Failed to fetch languages. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
