import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:niloufer_valet_mobile/api/oauth/refresh_api_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class BaseHttpService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  const BaseHttpService({
    required this.baseUrl,
    required this.defaultHeaders,
  });

  Future<http.Response> postJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    bool retryOn401 = true,
  }) async {
    return _executePostWithRetry(
      path: path,
      headers: headers,
      body: body,
      timeout: timeout,
      retryOn401: retryOn401,
    );
  }

  Future<http.Response> getJson(
    String path, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
    bool retryOn401 = true,
  }) async {
    return _executeGetWithRetry(
      path: path,
      headers: headers,
      timeout: timeout,
      retryOn401: retryOn401,
    );
  }

  Future<http.Response> _executePostWithRetry({
    required String path,
    Map<String, String>? headers,
    Object? body,
    required Duration timeout,
    required bool retryOn401,
    bool isRetry = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = {...defaultHeaders, ...?headers};

    try {
      final response = await http
          .post(uri, headers: mergedHeaders, body: jsonEncode(body))
          .timeout(timeout);
      _throwIfHttpError(response);
      return response;
    } on ApiException catch (e) {
      // If 401 and retry is enabled and not already retrying, try to refresh token
      if (e.statusCode == 401 && retryOn401 && !isRetry) {
        final hasToken = await _hasAccessToken();
        if (hasToken) {
          try {
            await RefreshApiService.refreshToken();
            // Update headers with new token
            final updatedHeaders = await _updateHeadersWithNewToken(headers);
            // Retry the request with updated headers
            return _executePostWithRetry(
              path: path,
              headers: updatedHeaders,
              body: body,
              timeout: timeout,
              retryOn401: false, // Prevent infinite retry
              isRetry: true,
            );
          } catch (refreshError) {
            // If refresh fails, throw the original 401 error
            throw e;
          }
        }
      }
      rethrow;
    } on SocketException {
      throw ApiException(
        'No internet connection. Please check your network and try again.',
        code: 'network_error',
      );
    } on TimeoutException {
      throw ApiException(
        'Request timed out. Please try again.',
        code: 'timeout',
      );
    }
  }

  Future<http.Response> _executeGetWithRetry({
    required String path,
    Map<String, String>? headers,
    required Duration timeout,
    required bool retryOn401,
    bool isRetry = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = {...defaultHeaders, ...?headers};

    try {
      final response =
          await http.get(uri, headers: mergedHeaders).timeout(timeout);
      _throwIfHttpError(response);
      return response;
    } on ApiException catch (e) {
      // If 401 and retry is enabled and not already retrying, try to refresh token
      if (e.statusCode == 401 && retryOn401 && !isRetry) {
        final hasToken = await _hasAccessToken();
        if (hasToken) {
          try {
            await RefreshApiService.refreshToken();
            // Update headers with new token
            final updatedHeaders = await _updateHeadersWithNewToken(headers);
            // Retry the request with updated headers
            return _executeGetWithRetry(
              path: path,
              headers: updatedHeaders,
              timeout: timeout,
              retryOn401: false, // Prevent infinite retry
              isRetry: true,
            );
          } catch (refreshError) {
            // If refresh fails, throw the original 401 error
            throw e;
          }
        }
      }
      rethrow;
    } on SocketException {
      throw ApiException(
        'No internet connection. Please check your network and try again.',
        code: 'network_error',
      );
    } on TimeoutException {
      throw ApiException(
        'Request timed out. Please try again.',
        code: 'timeout',
      );
    }
  }

  Future<bool> _hasAccessToken() async {
    try {
      final token = await TokenStorage.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, String>?> _updateHeadersWithNewToken(
    Map<String, String>? headers,
  ) async {
    if (headers == null) return null;

    final cookieHeader = headers['Cookie'] ?? headers['cookie'];
    if (cookieHeader == null || !cookieHeader.contains('accessToken=')) {
      return headers;
    }

    // Get new tokens
    final newAccessToken = await TokenStorage.getAccessToken();
    final newRefreshToken = await TokenStorage.getRefreshToken();

    if (newAccessToken == null) return headers;

    // Rebuild cookie string with new tokens
    final cookieParts = <String>[];
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      cookieParts.add('refreshToken=$newRefreshToken');
    }
    cookieParts.add('accessToken=$newAccessToken');

    final updatedHeaders = Map<String, String>.from(headers);
    updatedHeaders['Cookie'] = cookieParts.join('; ');
    return updatedHeaders;
  }

  void _throwIfHttpError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String msg = 'Request failed with status code ${response.statusCode}.';
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final message = body['message'];
        if (message is String) {
          msg = message;
        } else if (message is List) {
          // Handle array of messages - join them with newlines
          final messageList =
              message.whereType<String>().where((m) => m.isNotEmpty).toList();
          if (messageList.isNotEmpty) {
            msg = messageList.join('\n');
          }
        }
      }
    } catch (_) {}
    throw ApiException(
      msg,
      statusCode: response.statusCode,
      code: 'http_error',
    );
  }
}
