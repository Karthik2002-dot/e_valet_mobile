import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_http_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/services/oauth/session_manager.dart';

class LogoutApiService {
  LogoutApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static Future<bool> logout() async {
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

    try {
      await http.postJson('/auth/logout'); // throws ApiException on failure
    } on ApiException {
      // even if API fails, local logout should continue
    }

    await TokenStorage.clearAll();
    await SessionManager.clearSessionFlags();
    return true;
  }
}
