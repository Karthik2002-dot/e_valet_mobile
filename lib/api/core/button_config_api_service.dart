import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/button_config.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class ButtonConfigApiService {
  ButtonConfigApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<ButtonConfig> getButtonConfig() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }

    final base = BaseDioService(
      _baseUrl,
      ApiConfig.authorizedHeaders(accessToken),
    );

    try {
      final response = await base.get('/miscellaneous/button-config');
      final data = response.data as Map<String, dynamic>;
      return ButtonConfig.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Failed to fetch button config. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
