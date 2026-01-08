import 'dart:convert';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_http_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/verify_reset_otp_request.dart';
import 'package:niloufer_valet_mobile/models/oauth/verify_reset_otp_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class VerifyResetOtpApiService {
  VerifyResetOtpApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static final _http = BaseHttpService(
    baseUrl: _baseUrl,
    defaultHeaders: ApiConfig.apiKeyHeaders(_apiKey),
  );

  static Future<VerifyResetOtpResponse> verifyPasswordResetOtp({
    required String identifier,
    required String otp,
  }) async {
    final body = VerifyResetOtpRequest(
      identifier: identifier,
      otp: otp,
    ).toJson();

    try {
      final response = await _http.postJson(
        '/auth/verify-reset-otp',
        body: body,
      );

      final decoded = jsonDecode(response.body);

      String? message;
      String? resetToken;

      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] is String) {
          message = decoded['message'] as String;
        }
        if (decoded['resetToken'] is String) {
          resetToken = decoded['resetToken'] as String;
        } else if (decoded['data'] is Map &&
            (decoded['data'] as Map)['resetToken'] is String) {
          resetToken = (decoded['data'] as Map)['resetToken'] as String;
        }
      }

      if (resetToken != null && resetToken.isNotEmpty) {
        await TokenStorage.saveResetToken(resetToken);
      }

      return VerifyResetOtpResponse(
        message: message ?? 'OTP verified successfully.',
        resetToken: resetToken,
      );
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
