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
  /// Response: { "sessionId", "newAssignmentId", "assignedTo", "assignedAt", "message" }
  static Future<String> passSessionToDriver({
    required String sessionId,
    String? driverUserId,
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
        data: (driverUserId != null && driverUserId.isNotEmpty)
            ? <String, dynamic>{'driverUserId': driverUserId}
            : null,
      );

      final data = response.data as Map<String, dynamic>?;
      return (data?['message'] as String?) ?? 'Request passed successfully.';
    } on ApiException catch (e) {
      print('[PASS API] ApiException');
      print('[PASS API] Status: ${e.statusCode ?? 'N/A'}');
      print('[PASS API] Code: ${e.code}');
      print('[PASS API] Message: ${e.message}');
      rethrow;
    } catch (e) {
      print('[PASS API] Unexpected error: $e');
      throw ApiException(
        'Failed to pass session: $e',
        code: 'pass_session_error',
      );
    }
  }
}
