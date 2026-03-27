import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/session/pass_available_driver.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class PassAvailableDriversApiService {
  PassAvailableDriversApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  /// GET /sessions/{sessionId}/pass-available-drivers
  /// Returns the list of drivers this session can be passed to.
  static Future<List<PassAvailableDriver>> getAvailableDrivers({
    required String sessionId,
  }) async {
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
      final response =
          await base.get('/sessions/$sessionId/pass-available-drivers');

      final data = response.data as Map<String, dynamic>;
      final rawList = data['drivers'] as List<dynamic>? ?? [];
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(PassAvailableDriver.fromJson)
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Failed to load available drivers: $e',
        code: 'pass_drivers_error',
      );
    }
  }

  /// POST /sessions/{sessionId}/pass
  /// Passes the session to the target driver.
  /// Body: { "driverId": "<targetDriverId>" }
  static Future<String> passSessionToDriver({
    required String sessionId,
    required String driverId,
  }) async {
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
        '/sessions/$sessionId/pass',
        data: <String, dynamic>{'driverId': driverId},
      );

      final data = response.data as Map<String, dynamic>?;
      return (data?['message'] as String?) ?? 'Session passed successfully';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Failed to pass session: $e',
        code: 'pass_session_error',
      );
    }
  }
}
