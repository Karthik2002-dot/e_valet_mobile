import 'dart:convert';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_http_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/logout_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/services/oauth/session_manager.dart';

class LogoutApiService {
  LogoutApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static Future<LogoutResponse> logout() async {
    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();

    final cookieParts = <String>[];
    if (refreshToken != null && refreshToken.isNotEmpty) {
      cookieParts.add('refreshToken=$refreshToken');
    }
    if (accessToken != null && accessToken.isNotEmpty) {
      cookieParts.add('accessToken=$accessToken');
    }

    final http = BaseHttpService(
      baseUrl: _baseUrl,
      defaultHeaders: {
        ...ApiConfig.apiKeyHeaders(_apiKey),
        if (cookieParts.isNotEmpty) 'Cookie': cookieParts.join('; '),
      },
    );

    LogoutResponse response;
    try {
      final httpResponse = await http.postJson(
        '/auth/logout',
        body: '',
      ); // throws ApiException on failure

      final json = jsonDecode(httpResponse.body) as Map<String, dynamic>;
      response = LogoutResponse.fromJson(json);
    } on ApiException catch (e) {
      print(
          '🟢 LOGOUT API ERROR: ApiException: ${e.message} (code: ${e.code})');
      // even if API fails, local logout should continue
      // Return a default response
      response = LogoutResponse(message: 'Logged out locally');
    } catch (e) {
      print('🟢 LOGOUT API ERROR: Unknown error: $e');
      response = LogoutResponse(message: 'Logged out locally');
    }

    // Always clear local tokens and session, even if API call failed
    await TokenStorage.clearAll();
    await SessionManager.clearSessionFlags();

    return response;
  }
}
