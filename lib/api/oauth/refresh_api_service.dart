// lib/api/oauth/refresh_api_service.dart
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class RefreshApiService {
  RefreshApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static Future<void> refreshToken() async {
    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiException('Refresh token not found. Please login again.',
          code: 'no_refresh');
    }

    final cookieParts = <String>[];
    cookieParts.add('refreshToken=$refreshToken');
    if (accessToken != null && accessToken.isNotEmpty) {
      cookieParts.add('accessToken=$accessToken');
    }

    final base = BaseDioService(_baseUrl, {
      'Accept': '*/*',
      'X-API-Key': _apiKey,
      'Cookie': cookieParts.join('; '),
    });

    final response = await base.post('/auth/refresh');

    // Parse Set-Cookie headers from response and update TokenStorage
    final headers = response.headers;
    final setCookieHeaderValue = headers['set-cookie'] ?? headers['Set-Cookie'];
    
    String? newAccessToken;
    String? newRefreshToken;

    // Dio Headers returns List<String>? for header values
    if (setCookieHeaderValue != null) {
      // setCookieHeaderValue is List<String> from Dio Headers
      for (final cookieHeader in setCookieHeaderValue) {
        // Split into individual cookies, then into attributes
        for (final cookie in cookieHeader.split(',')) {
          for (final part in cookie.split(';')) {
            final trimmed = part.trim();
            if (trimmed.startsWith('accessToken=')) {
              newAccessToken = trimmed.substring('accessToken='.length).split(';').first.trim();
            } else if (trimmed.startsWith('refreshToken=')) {
              newRefreshToken = trimmed.substring('refreshToken='.length).split(';').first.trim();
            }
          }
        }
      }
    }

    if (newAccessToken != null && newAccessToken.isNotEmpty) {
      await TokenStorage.saveAccessToken(newAccessToken);
    }
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      await TokenStorage.saveRefreshToken(newRefreshToken);
    }
  }
}
