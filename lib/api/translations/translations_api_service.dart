import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/translations/translations_response.dart';

class TranslationsApiService {
  TranslationsApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<TranslationsResponse> fetchTranslations(String languageCode) async {
    final base = BaseDioService(
      _baseUrl,
      ApiConfig.defaultJsonHeaders,
    );

    try {
      final response = await base.get(
        '/i18n/translations',
        queryParameters: {'language': languageCode},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ApiException(
          'Invalid response format for translations.',
          code: 'invalid_response',
        );
      }

      return TranslationsResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Failed to fetch translations. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
