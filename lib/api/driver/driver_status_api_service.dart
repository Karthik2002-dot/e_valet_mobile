import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/driver_status.dart';
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
}
