import 'dart:convert';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_http_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/phone_password_login_request.dart';

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

      // parse Set-Cookie headers + save tokens via TokenStorage here
      jsonDecode(response.body) as Map<String, dynamic>;

      return true;
    } on ApiException {
      rethrow; // let bloc/ui decide what to show
    }
  }
}
