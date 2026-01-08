import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/re-park/repark_request.dart';
import 'package:niloufer_valet_mobile/models/driver/re-park/repark_request_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class ReparkApiService {
  ReparkApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<ReparkRequestResponse> requestRepark({
    required String sessionId,
    required ReparkRequest request,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      print('❌ No access token found');
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
        '/sessions/$sessionId/repark/request',
        data: request.toJson(),
      );

      final data = response.data as Map<String, dynamic>;

      return ReparkRequestResponse.fromJson(data);
    } on ApiException catch (e) {
      print('❌ [RE-PARK API] HTTP Status Code: ${e.statusCode ?? 'N/A'}');
      print('❌ [RE-PARK API] API Exception: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [RE-PARK API] Unexpected error: $e');
      throw ApiException(
        'Failed to request re-park. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
