import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/manual_retrieval_request.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/manual_retrieval_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class OperatorManualRetrievalApiService {
  static String get _baseUrl => ApiConfig.valetBaseUrl;

  Future<ManualRetrievalResponse> createManualRetrievalRequest({
    required String outletId,
    required ManualRetrievalRequest request,
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
        '/operators/manual-retrieval-request',
        queryParameters: {
          'outletId': outletId,
        },
        data: request.toJson(),
      );

      return ManualRetrievalResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create manual retrieval request: $e');
    }
  }
}
