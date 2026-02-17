// lib/api/oauth/refresh_api_service.dart
import 'dart:convert';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/session_manager.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class RefreshApiService {
  RefreshApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  /// Called when refresh returns 401 (e.g. logged in on another device).
  /// App should set this to show a snackbar and navigate to login.
  static void Function(String message)? onSessionEnded;

  static Future<void> refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiException('Refresh token not found. Please login again.',
          code: 'no_refresh');
    }

    // Send refreshToken in Cookie header, empty body. Do not retry on 401 to avoid loop.
    final base = BaseDioService(_baseUrl, {
      'Accept': '*/*',
      'X-API-Key': _apiKey,
      'Cookie': 'refreshToken=$refreshToken',
    });

    try {
      // retryOn401: false so we don't call refresh again when /auth/refresh returns 401
      final response = await base.post(
        '/auth/refresh',
        data: '',
        retryOn401: false,
      );

      // Parse JSON response body and update TokenStorage
      final responseData = response.data;
      if (responseData == null) {
        throw ApiException(
          'Invalid response from refresh endpoint.',
          code: 'invalid_response',
        );
      }

      Map<String, dynamic> responseMap;
      if (responseData is Map) {
        responseMap = responseData as Map<String, dynamic>;
      } else if (responseData is String) {
        responseMap = jsonDecode(responseData) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'Invalid response format from refresh endpoint.',
          code: 'invalid_response',
        );
      }

      // Only accessToken is returned, refreshToken remains the same
      final newAccessToken = responseMap['accessToken'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await TokenStorage.saveAccessToken(newAccessToken);
        // Update expiry to 1 day from now
        final expiry = DateTime.now().add(const Duration(days: 1));
        await TokenStorage.saveAccessTokenExpiry(expiry);
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await TokenStorage.clearAll();
        await SessionManager.clearSessionFlags();
        onSessionEnded?.call(TextConstants.loggedOutAnotherDevice);
      }
      rethrow;
    }
  }
}
