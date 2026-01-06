import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_valet/valet_kpis_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class ValetKpisApiService {
  /// Get valet KPIs for a specific outlet
  static Future<ValetKpisResponse> getValetKpis({
    required String outletId,
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
        ApiConfig.valetBaseUrl,
        ApiConfig.authorizedHeaders(accessToken),
      );

      final response = await base.get(
        '/operators/valets/kpis',
        queryParameters: {'outletId': outletId},
      );
      return ValetKpisResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching valet KPIs: $e');
    }
  }
}
