import 'dart:async';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class RefreshApiService {
  RefreshApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static Future<void> refreshToken() async {
    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token not found. Please login again.');
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

    final response = await base.dio.post('/auth/refresh');
    // keep your Set‑Cookie parsing + TokenStorage update, but no env reads
  }
}
