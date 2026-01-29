import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/update_session_status_response.dart';

class OperatorUpdateSessionApiService {
  OperatorUpdateSessionApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<UpdateSessionStatusResponse> updateSessionStatus({
    required String sessionId,
    required String newStatus,
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
      // Debug: Print request details
      print('=== API REQUEST DEBUG ===');
      print('URL: $_baseUrl/operators/update-session');
      print('Method: PATCH');
      print(
          'Request Body: {"sessionId": "$sessionId", "newStatus": "$newStatus"}');
      print('========================');

      final response = await base.patch(
        '/operators/update-session',
        data: {
          'sessionId': sessionId,
          'newStatus': newStatus,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          final message =
              data is String ? data : 'Invalid response format from server.';
          throw ApiException(
            message,
            code: 'update_session_error',
            statusCode: response.statusCode,
          );
        }
        final updateResponse = UpdateSessionStatusResponse.fromJson(data);
        return updateResponse;
      } else {
        throw ApiException(
          'Failed to update session status. Status: ${response.statusCode}',
          code: 'update_session_error',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Error updating session status: $e',
        code: 'update_session_exception',
      );
    }
  }
}
