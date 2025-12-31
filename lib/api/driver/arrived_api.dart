import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/session/arrived_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class ArrivedApiService {
  ArrivedApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<ArrivedResponse> confirmArrival({
    required String sessionId,
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    print('🔄 Starting confirm arrival API call for sessionId: $sessionId');
    print('📍 Location: $location (lat: $latitude, lng: $longitude)');

    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      print('❌ No access token found');
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }

    print('✅ Access token found, making API call...');

    final base = BaseDioService(
      _baseUrl,
      ApiConfig.authorizedHeaders(accessToken),
    );

    try {
      print('📡 [ARRIVED API] Making POST request to: $_baseUrl/sessions/$sessionId/arrived');

      final requestBody = {
        'latitude': latitude,
        'longitude': longitude,
        'location': location,
      };

      print('📤 [ARRIVED API] Request body: $requestBody');

      final response = await base.post(
        '/sessions/$sessionId/arrived',
        data: requestBody,
      );

      print('📊 [ARRIVED API] HTTP Status Code: ${response.statusCode}');
      final data = response.data as Map<String, dynamic>;
      print('✅ [ARRIVED API] API Call Successful!');
      print('📄 [ARRIVED API] Full API Response: $data');
      print('🎯 [ARRIVED API] Session ID: ${data['sessionId']}');
      print('📊 [ARRIVED API] Status: ${data['status']}');
      print('🔢 [ARRIVED API] Card Number: ${data['cardNumber']}');
      print('⏰ [ARRIVED API] Arrived At: ${data['arrivedAt']}');
      print('💬 [ARRIVED API] Message: ${data['message']}');

      return ArrivedResponse.fromJson(data);
    } on ApiException catch (e) {
      print('❌ [ARRIVED API] HTTP Status Code: ${e.statusCode ?? 'N/A'}');
      print('❌ [ARRIVED API] API Exception: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [ARRIVED API] Unexpected error: $e');
      throw ApiException(
        'Failed to confirm arrival. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}

