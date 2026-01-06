import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get authBaseUrl => dotenv.env['OAUTH_BASE_URL'] ?? '';

  static String get authApiKey =>
      (dotenv.env['OAUTH_BASE_API_KEY'] ?? '').trim();

  static String get valetBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String get websocketBaseUrl =>
      dotenv.env['WEBSOCKET_BASE_URL'] ?? '';

  static Map<String, String> get defaultJsonHeaders => const {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
      };

  static Map<String, String> authorizedHeaders(String accessToken) {
    return {
      ...defaultJsonHeaders,
      'Authorization': 'Bearer $accessToken',
    };
  }

  static Map<String, String> apiKeyHeaders(String apiKey) {
    return {
      ...defaultJsonHeaders,
      'X-API-Key': apiKey,
    };
  }
}
