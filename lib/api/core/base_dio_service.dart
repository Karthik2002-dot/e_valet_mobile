import 'dart:io';
import 'package:dio/dio.dart';
import 'package:niloufer_valet_mobile/api/oauth/refresh_api_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class BaseDioService {
  final Dio dio;

  BaseDioService(String baseUrl, Map<String, String> defaultHeaders)
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: defaultHeaders,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool retryOn401 = true,
  }) async {
    return _executeGetWithRetry(
      path: path,
      queryParameters: queryParameters,
      options: options,
      retryOn401: retryOn401,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool retryOn401 = true,
  }) async {
    return _executePostWithRetry(
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      retryOn401: retryOn401,
    );
  }

  Future<Response<dynamic>> _executeGetWithRetry({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required bool retryOn401,
    bool isRetry = false,
  }) async {
    try {
      return await dio.get(path,
          queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      final apiException = _mapDioError(e);
      // If 401 and retry is enabled and not already retrying, try to refresh token
      if (apiException.statusCode == 401 && retryOn401 && !isRetry) {
        final hasToken = await _hasAccessToken();
        if (hasToken) {
          try {
            await RefreshApiService.refreshToken();
            // Update headers with new token
            final updatedOptions = await _updateOptionsWithNewToken(options);
            // Retry the request with updated headers
            return _executeGetWithRetry(
              path: path,
              queryParameters: queryParameters,
              options: updatedOptions,
              retryOn401: false, // Prevent infinite retry
              isRetry: true,
            );
          } catch (refreshError) {
            // If refresh fails, throw the original 401 error
            throw apiException;
          }
        }
      }
      throw apiException;
    }
  }

  Future<Response<dynamic>> _executePostWithRetry({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required bool retryOn401,
    bool isRetry = false,
  }) async {
    try {
      return await dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      final apiException = _mapDioError(e);
      // If 401 and retry is enabled and not already retrying, try to refresh token
      if (apiException.statusCode == 401 && retryOn401 && !isRetry) {
        final hasToken = await _hasAccessToken();
        if (hasToken) {
          try {
            await RefreshApiService.refreshToken();
            // Update headers with new token
            final updatedOptions = await _updateOptionsWithNewToken(options);
            // Retry the request with updated headers
            return _executePostWithRetry(
              path: path,
              data: data,
              queryParameters: queryParameters,
              options: updatedOptions,
              retryOn401: false, // Prevent infinite retry
              isRetry: true,
            );
          } catch (refreshError) {
            // If refresh fails, throw the original 401 error
            throw apiException;
          }
        }
      }
      throw apiException;
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

  Future<Options?> _updateOptionsWithNewToken(Options? options) async {
    if (options == null) {
      // Create new options with updated headers
      final newAccessToken = await TokenStorage.getAccessToken();
      final newRefreshToken = await TokenStorage.getRefreshToken();

      if (newAccessToken == null) return null;

      final cookieParts = <String>[];
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        cookieParts.add('refreshToken=$newRefreshToken');
      }
      cookieParts.add('accessToken=$newAccessToken');

      return Options(
        headers: {
          ...dio.options.headers,
          'Cookie': cookieParts.join('; '),
        },
      );
    }

    // Update existing options
    final headers = Map<String, dynamic>.from(options.headers ?? {});
    final cookieHeader = headers['Cookie'] ?? headers['cookie'];

    if (cookieHeader == null ||
        !cookieHeader.toString().contains('accessToken=')) {
      return options;
    }

    // Get new tokens
    final newAccessToken = await TokenStorage.getAccessToken();
    final newRefreshToken = await TokenStorage.getRefreshToken();

    if (newAccessToken == null) return options;

    // Rebuild cookie string with new tokens
    final cookieParts = <String>[];
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      cookieParts.add('refreshToken=$newRefreshToken');
    }
    cookieParts.add('accessToken=$newAccessToken');

    final updatedHeaders = Map<String, dynamic>.from(headers);
    updatedHeaders['Cookie'] = cookieParts.join('; ');

    return options.copyWith(headers: updatedHeaders);
  }

  ApiException _mapDioError(DioException e) {
    if (e.error is SocketException) {
      return ApiException(
        'No internet connection. Please check your network and try again.',
        code: 'network_error',
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException(
        'Request timed out. Please try again.',
        code: 'timeout',
      );
    }

    final status = e.response?.statusCode;
    if (status != null) {
      String msg = 'Request failed with status code $status.';
      final data = e.response?.data;
      if (data is Map) {
        final message = data['message'];
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
      return ApiException(msg, statusCode: status, code: 'http_error');
    }

    return ApiException(
      e.message ?? 'Unexpected error occurred.',
      code: 'unknown',
    );
  }
}
