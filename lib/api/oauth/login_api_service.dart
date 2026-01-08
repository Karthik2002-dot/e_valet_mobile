import 'dart:convert';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_http_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/phone_password_login_request.dart';
import 'package:niloufer_valet_mobile/models/oauth/profile.dart';
import 'package:niloufer_valet_mobile/models/oauth/user_profile.dart';
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

  static Future<Profile> verifyPhonePasswordLogin(
    PhonePasswordLoginRequest request,
  ) async {
    final body = request.toJson();

    try {
      final response = await _http.postJson(
        '/auth/login',
        body: body,
      ); // throws ApiException on error

      // Parse JSON response body and persist tokens for subsequent API calls
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Extract tokens from response
      final accessToken = responseData['accessToken'] as String?;
      final refreshToken = responseData['refreshToken'] as String?;

      if (accessToken != null && accessToken.isNotEmpty) {
        await TokenStorage.saveAccessToken(accessToken);
        // Assume access token expires in 15 minutes
        final expiry = DateTime.now().add(const Duration(minutes: 15));
        await TokenStorage.saveAccessTokenExpiry(expiry);
      }
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await TokenStorage.saveRefreshToken(refreshToken);
      }

      // Extract and save user information if available
      final userJson = responseData['user'] as Map<String, dynamic>? ?? {};
      final application =
          responseData['application'] as Map<String, dynamic>? ?? {};

      // Build Profile object (application contains id/name/roles)
      final user = UserProfile.fromJson(userJson);
      final applicationId = (application['id'] ?? '').toString();
      final rolesList = (application['roles'] as List<dynamic>? ?? [])
          .map((r) => r.toString())
          .toList();

      // Save display name if available
      if (user.firstName.isNotEmpty && user.lastName.isNotEmpty) {
        await TokenStorage.saveUserName(
          firstName: user.firstName,
          lastName: user.lastName,
        );
      }

      // Mark session as active for today
      await SessionManager.markLoggedInForToday();

      return Profile(
        user: user,
        applicationId: applicationId,
        roles: rolesList,
      );
    } on ApiException {
      rethrow; // let bloc/ui decide what to show
    }
  }
}
