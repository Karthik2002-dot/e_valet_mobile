import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:niloufer_valet_mobile/api/core/api_config.dart';

class LoginApiService {
  LoginApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _passwordLoginApiKey => ApiConfig.authApiKey;

  static Future<bool> verifyPhonePasswordLogin({
    required String phone,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');

    final headers = {
      ...ApiConfig.apiKeyHeaders(_passwordLoginApiKey),
    };

    final body = jsonEncode({
      'loginType': 'PHONE_PASSWORD',
      'phoneNumber': phone,
      'password': password,
    });

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // keep your existing cookie parsing + TokenStorage logic here
      // ...
      return true;
    }
    return false;
  }
}
