import 'package:flutter/foundation.dart';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/models/oauth/profile_response.dart';

class ProfileApiService {
  ProfileApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static Future<ProfileResponse> getProfile() async {
    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException('Access token not found. Please login again.',
          code: 'no_token');
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
    });

    try {
      final response =
          await base.get('/auth/profile'); // wrapper from BaseDioService

      final data = response.data as Map<String, dynamic>;
      debugPrint('ProfileApiService: Raw response data: $data');
      final profileResponse = ProfileResponse.fromJson(data);
      debugPrint(
          'ProfileApiService: Parsed roles: ${profileResponse.roles}, normalized: ${profileResponse.normalizedRoles}');
      return profileResponse;
    } on ApiException {
      rethrow;
    }
  }
}
