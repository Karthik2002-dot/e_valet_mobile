import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/change_password_request.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class PasswordApiService {
  PasswordApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static Future<void> changePassword(
    ChangePasswordRequest request,
  ) async {
    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }

    final cookieParts = <String>[];
    if (refreshToken != null && refreshToken.isNotEmpty) {
      cookieParts.add('refreshToken=$refreshToken');
    }
    cookieParts.add('accessToken=$accessToken');

    final base = BaseDioService(_baseUrl, {
      'Accept': 'application/json, text/plain, */*',
      'x-api-key': _apiKey,
      'Cookie': cookieParts.join('; '),
      'Content-Type': 'application/json',
    });

    try {
      await base.post(
        '/auth/change-password',
        data: request.toJson(),
      );
    } on ApiException {
      rethrow;
    }
  }
}
