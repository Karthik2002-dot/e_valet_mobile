import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/api/driver/image_API.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/session/accept_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class RetrievalAcceptApiService {
  RetrievalAcceptApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<AcceptResponse> acceptSession({
    required String sessionId,
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    print('🔄 Starting accept API call with sessionId from GET API: $sessionId');
    print('📍 [ACCEPT API] Location: $location (lat: $latitude, lng: $longitude)');

    // Check if this matches the session ID stored in TokenStorage
    final storedSessionId = await TokenStorage.getSessionId();
    print('💾 Driver session ID in TokenStorage: $storedSessionId');
    print('🔍 SessionId from GET API vs Driver session ID: $sessionId != $storedSessionId');

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
      print('📡 [ACCEPT API] Making POST request to: $_baseUrl/sessions/$sessionId/accept');
      print('🔑 [ACCEPT API] Using sessionId from GET API in URL: $sessionId');

      final requestBody = {
        'latitude': latitude,
        'longitude': longitude,
        'location': location,
      };

      print('📤 [ACCEPT API] Request body: $requestBody');

      final response = await base.post(
        '/sessions/$sessionId/accept',
        data: requestBody,
      );

      print('📊 [ACCEPT API] HTTP Status Code: ${response.statusCode}');
      final data = response.data as Map<String, dynamic>;
      print('✅ [ACCEPT API] API Call Successful!');
      print('📄 [ACCEPT API] Full API Response: $data');
      print('🎯 [ACCEPT API] Response Session ID: ${data['sessionId']}');
      print('📊 [ACCEPT API] Response Status: ${data['status']}');
      print('🔢 [ACCEPT API] Response Card Number: ${data['cardNumber']}');
      print('⏰ [ACCEPT API] Response Accepted At: ${data['acceptedAt']}');
      print('💬 [ACCEPT API] Response Message: ${data['message']}');

      // Check if there's a pending photo to upload
      final pendingPhotoPath = await TokenStorage.getPendingPhotoPath();
      if (pendingPhotoPath != null && pendingPhotoPath.isNotEmpty) {
        print('📸 Found pending photo, uploading now: $pendingPhotoPath');
        try {
          await ImageApiService.uploadParkingPhoto(
            imagePath: pendingPhotoPath,
            sessionId: sessionId,
          );
          print('✅ Pending photo uploaded successfully');
          await TokenStorage.clearPendingPhotoPath();
        } catch (photoError) {
          print('❌ Failed to upload pending photo: $photoError');
          // Don't fail the whole operation if photo upload fails
        }
      }

      return AcceptResponse.fromJson(data);
    } on ApiException catch (e) {
      print('❌ [ACCEPT API] HTTP Status Code: ${e.statusCode ?? 'N/A'}');
      print('❌ [ACCEPT API] API Exception: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [ACCEPT API] Unexpected error: $e');
      throw ApiException(
        'Failed to accept session. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
