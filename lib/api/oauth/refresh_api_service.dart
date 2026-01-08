// lib/api/oauth/refresh_api_service.dart
import 'dart:convert';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class RefreshApiService {
  RefreshApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static Future<void> refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiException('Refresh token not found. Please login again.',
          code: 'no_refresh');
    }

    // Send refreshToken in Cookie header, empty body
    final base = BaseDioService(_baseUrl, {
      'Accept': '*/*',
      'X-API-Key': _apiKey,
      'Cookie': 'refreshToken=$refreshToken',
    });

    // Send empty body as per API specification
    final response = await base.post('/auth/refresh', data: '');

    // Parse JSON response body and update TokenStorage
    final responseData = response.data;
    if (responseData == null) {
      throw ApiException('Invalid response from refresh endpoint.',
          code: 'invalid_response');
    }

    Map<String, dynamic> responseMap;
    if (responseData is Map) {
      responseMap = responseData as Map<String, dynamic>;
    } else if (responseData is String) {
      responseMap = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      throw ApiException('Invalid response format from refresh endpoint.',
          code: 'invalid_response');
    }

    // Only accessToken is returned, refreshToken remains the same
    final newAccessToken = responseMap['accessToken'] as String?;

    if (newAccessToken != null && newAccessToken.isNotEmpty) {
      await TokenStorage.saveAccessToken(newAccessToken);
      // Update expiry to 15 minutes from now
      final expiry = DateTime.now().add(const Duration(minutes: 15));
      await TokenStorage.saveAccessTokenExpiry(expiry);
    }
  }
}
