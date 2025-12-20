import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/status/driver_status.dart';
import 'package:niloufer_valet_mobile/models/driver/status/clock_in_request.dart';
import 'package:niloufer_valet_mobile/models/driver/status/clock_in_response.dart';
import 'package:niloufer_valet_mobile/models/driver/status/clock_out_request.dart';
import 'package:niloufer_valet_mobile/models/driver/status/clock_out_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class DriverStatusApiService {
  DriverStatusApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<DriverStatus> getDriverStatus() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }

    final base = BaseDioService(
      _baseUrl,
      ApiConfig.authorizedHeaders(accessToken),
    );

    try {
      final response = await base.get('/drivers/me/status');

      final data = response.data as Map<String, dynamic>;
      return DriverStatus.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Failed to fetch driver status. Please try again.',
        code: 'unknown_error',
      );
    }
  }

  /// Clock in (go online) with location
  static Future<ClockInResponse> clockIn(ClockInRequest request) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }

    final base = BaseDioService(
      _baseUrl,
      ApiConfig.authorizedHeaders(accessToken),
    );

    try {
      final response = await base.post(
        '/drivers/clock-in',
        data: request.toJson(),
      );

      final data = response.data as Map<String, dynamic>;
      return ClockInResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Failed to clock in. Please try again.',
        code: 'unknown_error',
      );
    }
  }

  /// Clock out (go offline) with location
  static Future<ClockOutResponse> clockOut(ClockOutRequest request) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }

    final base = BaseDioService(
      _baseUrl,
      ApiConfig.authorizedHeaders(accessToken),
    );

    try {
      final response = await base.post(
        '/drivers/clock-out',
        data: request.toJson(),
      );

      final data = response.data as Map<String, dynamic>;
      return ClockOutResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Failed to clock out. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
