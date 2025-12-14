import 'dart:async';
import 'package:dio/dio.dart';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/models/oauth/profile.dart';

class ProfileApiService {
  ProfileApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static Future<Profile> getProfile() async {
    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token not found. Please login again.');
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
      final response = await base.dio.get('/auth/profile');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;
        return Profile.fromJson(data);
      }

      // Non‑2xx -> throw so caller can handle
      throw Exception(
        'Failed to fetch profile. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      // Optionally handle 401 with refresh+retry here; otherwise just rethrow
      throw Exception(
          'Failed to fetch profile: ${e.message ?? 'Unknown error'}');
    }
  }
}
