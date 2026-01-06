import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/assign_retrieval_request.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/assign_retrieval_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class OperatorAssignRetrievalApiService {
  static String get _baseUrl => ApiConfig.valetBaseUrl;

  Future<AssignRetrievalResponse> assignRetrieval({
    required AssignRetrievalRequest request,
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
        '/operators/assign-retrieval',
        data: request.toJson(),
      );

      return AssignRetrievalResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to assign retrieval: $e');
    }
  }
}
