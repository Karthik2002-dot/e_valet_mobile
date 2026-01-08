import 'package:dio/dio.dart';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class ReparkApiService {
  ReparkApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  /// Upload re-parked car photo to the session
  /// POST /api/v1/sessions/{id}/repark
  static Future<Map<String, dynamic>> uploadReparkPhoto({
    required String imagePath,
    required String sessionId,
    String? description, // Optional notes about re-parking location
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
      // Create multipart form data
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        if (description != null && description.isNotEmpty)
          'description': description,
      });

      // Make the API call
      final response = await base.post(
        '/sessions/$sessionId/repark',
        data: formData,
      );

      final responseData = response.data as Map<String, dynamic>;

      return responseData;
    } on DioException catch (e) {
      print('❌ [RE-PARK UPLOAD] DioException caught:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');

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
          'Failed to upload re-park photo. Please try again.',
          code: 'upload_failed',
        );
      }
    } on ApiException catch (e) {
      print('❌ [RE-PARK UPLOAD] ApiException: ${e.message} (${e.code})');
      rethrow;
    } catch (e) {
      print('❌ [RE-PARK UPLOAD] Unknown error: $e');
      throw ApiException(
        'Failed to upload re-park photo. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
