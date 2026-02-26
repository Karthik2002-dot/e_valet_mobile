import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_valet/valet_logout_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

/// POST /api/v1/users/{id}/applications/{applicationId}/logout
/// Logs out a valet (user) from the application. Uses [userId] and [applicationId] from env (EVALET_APPLICATION_BASE_URL).
class ValetLogoutApiService {
  ValetLogoutApiService._();

  static String get _baseUrl => ApiConfig.authBaseUrl;
  static String get _apiKey => ApiConfig.authApiKey;

  static Future<ValetLogoutResponse> logoutValet({required String userId}) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }
    final applicationId = ApiConfig.evaletApplicationId;
    if (applicationId.isEmpty) {
      throw ApiException(
        'Application ID not configured. Set EVALET_APPLICATION_BASE_URL and EVALET_APPLICATION_DEV_ID (or EVALET_APPLICATION_PROD_ID) in .env.',
        code: 'no_application_id',
      );
    }

    final headers = <String, String>{
      ...ApiConfig.defaultJsonHeaders,
      'Authorization': 'Bearer $accessToken',
      'X-API-Key': _apiKey,
    };

    final base = BaseDioService(_baseUrl, headers);
    final path = '/users/$userId/applications/$applicationId/logout';
    final fullUrl = '$_baseUrl$path';
    const body = <String, dynamic>{};

    // Print request
    print('🔵 VALET LOGOUT REQUEST:');
    print('   Method: POST');
    print('   URL: $fullUrl');
    print('   userId (path): $userId');
    print('   applicationId (path): $applicationId');
    print('   body: $body');

    try {
      final response = await base.post(path, data: body);

      // Print response
      print('🔵 VALET LOGOUT RESPONSE:');
      print('   statusCode: ${response.statusCode}');
      print('   data: ${response.data}');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ValetLogoutResponse.fromJson(data);
      }
      return ValetLogoutResponse();
    } on ApiException catch (e) {
      print('🔵 VALET LOGOUT ERROR RESPONSE:');
      print('   message: ${e.message}');
      print('   code: ${e.code}');
      print('   statusCode: ${e.statusCode}');
      rethrow;
    }
  }
}
