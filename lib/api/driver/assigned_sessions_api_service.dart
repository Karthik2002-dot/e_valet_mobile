import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class AssignedSessionsApiService {
  AssignedSessionsApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<List<AssignedSession>> fetchAssignedSessions() async {
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

    try {
      print('Fetching assigned sessions from API...');
      final response = await base.get('/sessions/assigned-to-me');
      final data = response.data;
      print('API response data: $data');

      if (data is! Map<String, dynamic>) {
        throw ApiException(
          'Invalid response format for assigned sessions.',
          code: 'invalid_response',
        );
      }

      final sessions = (data['sessions'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AssignedSession.fromJson)
              .toList() ??
          [];

      print('Parsed sessions: ${sessions.length} items');
      // Commented out detailed session prints to prevent potential performance issues
      // for (var i = 0; i < sessions.length; i++) {
      //   print('Session $i: ${sessions[i].toJson()}');
      // }
      return sessions;
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error fetching assigned sessions: $e');
      throw ApiException(
        'Failed to load assigned sessions.',
        code: 'unknown_error',
      );
    }
  }

  static Future<AssignedSession?> fetchFirstAssignedSession() async {
    final sessions = await fetchAssignedSessions();
    if (sessions.isEmpty) return null;
    return sessions.first;
  }
}
