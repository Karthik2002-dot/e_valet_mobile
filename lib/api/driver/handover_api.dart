import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/session/handover_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class HandoverApiService {
  HandoverApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<HandoverResponse> confirmHandover({
    required String sessionId,
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    print('🔄 [HANDOVER API] Starting confirm handover API call for sessionId: $sessionId');
    print('📍 [HANDOVER API] Location: $location (lat: $latitude, lng: $longitude)');

    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      print('❌ [HANDOVER API] No access token found');
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }

    print('✅ [HANDOVER API] Access token found, making API call...');

    final base = BaseDioService(
      _baseUrl,
      ApiConfig.authorizedHeaders(accessToken),
    );

    try {
      print('📡 [HANDOVER API] Making POST request to: $_baseUrl/sessions/$sessionId/handover');

      final requestBody = {
        'latitude': latitude,
        'longitude': longitude,
        'location': location,
      };

      print('📤 [HANDOVER API] Request body: $requestBody');

      final response = await base.post(
        '/sessions/$sessionId/handover',
        data: requestBody,
      );

      print('📊 [HANDOVER API] HTTP Status Code: ${response.statusCode}');
      final data = response.data as Map<String, dynamic>;
      print('✅ [HANDOVER API] API Call Successful!');
      print('📄 [HANDOVER API] Full API Response: $data');
      print('🎯 [HANDOVER API] Session ID: ${data['sessionId']}');
      print('📊 [HANDOVER API] Status: ${data['status']}');
      print('🔢 [HANDOVER API] Card Number: ${data['cardNumber']}');
      print('⏰ [HANDOVER API] Handed Over At: ${data['handedOverAt']}');
      print('💬 [HANDOVER API] Message: ${data['message']}');

      return HandoverResponse.fromJson(data);
    } on ApiException catch (e) {
      print('❌ [HANDOVER API] HTTP Status Code: ${e.statusCode ?? 'N/A'}');
      print('❌ [HANDOVER API] API Exception: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [HANDOVER API] Unexpected error: $e');
      throw ApiException(
        'Failed to confirm handover. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}

