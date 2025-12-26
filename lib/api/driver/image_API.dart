import 'package:dio/dio.dart';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class ImageApiService {
  ImageApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  /// Upload parking photo to the session
  /// POST /api/v1/sessions/{id}/park
  static Future<Map<String, dynamic>> uploadParkingPhoto({
    required String imagePath,
  }) async {
    // Get session ID from Hive storage
    final sessionId = await TokenStorage.getSessionId();

    if (sessionId == null || sessionId.isEmpty) {
      print('❌ No session ID found!');
      throw ApiException(
        'No active session. Please check in first.',
        code: 'no_session',
      );
    }

    // Get access token
    final accessToken = await TokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      print('❌ No access token found!');
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
      // Create multipart form data
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        // description is optional, so we don't send it
      });

      // Make the API call
      final response = await base.post(
        '/sessions/$sessionId/park',
        data: formData,
      );

      // Return the response data
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('❌ DioException caught:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('Error Type: ${e.type}');

      if (e.response?.statusCode == 404) {
        throw ApiException(
          'Session not found. Please check in again.',
          code: 'session_not_found',
        );
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data?['message'] ?? 'Invalid request';
        throw ApiException(message, code: 'bad_request');
      } else if (e.response?.statusCode == 413) {
        throw ApiException(
          'Image file is too large. Please try a smaller image.',
          code: 'file_too_large',
        );
      } else {
        throw ApiException(
          'Failed to upload photo. Please try again.',
          code: 'upload_failed',
        );
      }
    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message} (${e.code})');
      rethrow;
    } catch (e) {
      print('❌ Unknown error: $e');
      print('Error type: ${e.runtimeType}');
      throw ApiException(
        'Failed to upload photo. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
