import 'dart:convert';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_http_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/request_otp_request.dart';

class OtpApiService {
  OtpApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static final _http = BaseHttpService(
    baseUrl: _baseUrl,
    defaultHeaders: ApiConfig.apiKeyHeaders(_apiKey),
  );

  static Future<String> requestPasswordResetOtp(String identifier) async {
    final body = RequestOtpRequest(
      identifier: identifier,
      purpose: 'PASSWORD_RESET',
    ).toJson();

    try {
      final response = await _http.postJson(
        '/auth/request-otp',
        body: body,
      );

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> &&
          decoded['message'] is String &&
          (decoded['message'] as String).isNotEmpty) {
        return decoded['message'] as String;
      }

      return 'OTP sent successfully.';
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Something went wrong. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
