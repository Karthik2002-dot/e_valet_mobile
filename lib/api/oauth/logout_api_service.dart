import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/services/oauth/session_manager.dart';

class LogoutApiService {
  LogoutApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;

  static Future<bool> logout() async {
    final uri = Uri.parse('$_baseUrl/auth/logout');
    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();

    final cookieParts = <String>[];
    if (refreshToken != null && refreshToken.isNotEmpty) {
      cookieParts.add('refreshToken=$refreshToken');
    }
    if (accessToken != null && accessToken.isNotEmpty) {
      cookieParts.add('accessToken=$accessToken');
    }

    final headers = {
      ...ApiConfig.apiKeyHeaders(ApiConfig.authApiKey),
      if (cookieParts.isNotEmpty) 'Cookie': cookieParts.join('; '),
    };

    final response = await http
        .post(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    await TokenStorage.clearAllTokens();
    await TokenStorage.clearUserName();
    await SessionManager.clearSessionFlags();

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
