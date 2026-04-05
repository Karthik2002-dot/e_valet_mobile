import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/cancel_assignment_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class OperatorCancelAssignmentApiService {
  static String get _baseUrl => ApiConfig.valetBaseUrl;

  Future<CancelAssignmentResponse> cancelAssignment({
    required String sessionId,
  }) async {
    try {
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
      final response = await base.post(
        '/operators/cancel-assignment',
        data: {'sessionId': sessionId},
      );
      return CancelAssignmentResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Failed to cancel assignment. Please try again later.',
        code: 'cancel_assignment_error',
      );
    }
  }
}
