import 'dart:convert';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_http_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/phone_password_login_request.dart';
import 'package:niloufer_valet_mobile/services/oauth/session_manager.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class LoginApiService {
  LoginApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static final _http = BaseHttpService(
    baseUrl: _baseUrl,
    defaultHeaders: ApiConfig.apiKeyHeaders(_apiKey),
  );

  static Future<bool> verifyPhonePasswordLogin(
    PhonePasswordLoginRequest request,
  ) async {
    final body = request.toJson();

    try {
      final response = await _http.postJson(
        '/auth/login',
        body: body,
      ); // throws ApiException on error

      // Parse Set-Cookie headers and persist tokens for subsequent API calls
      final setCookieHeader = response.headers['set-cookie'];
      if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
        String? accessToken;
        String? refreshToken;

        // Split into individual cookies, then into attributes
        for (final cookie in setCookieHeader.split(',')) {
          for (final part in cookie.split(';')) {
            final trimmed = part.trim();
            if (trimmed.startsWith('accessToken=')) {
              accessToken = trimmed.substring('accessToken='.length);
            } else if (trimmed.startsWith('refreshToken=')) {
              refreshToken = trimmed.substring('refreshToken='.length);
            }
          }
        }

        if (accessToken != null && accessToken.isNotEmpty) {
          await TokenStorage.saveAccessToken(accessToken);
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await TokenStorage.saveRefreshToken(refreshToken);
        }

        // Mark session as active for today
        await SessionManager.markLoggedInForToday();
      }

      // Optionally parse response body if needed later
      jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    } on ApiException {
      rethrow; // let bloc/ui decide what to show
    }
  }
}
