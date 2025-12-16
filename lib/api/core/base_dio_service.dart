import 'dart:io';
import 'package:dio/dio.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

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
  }) async {
    try {
      return await dio.get(path,
          queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
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
      if (data is Map && data['message'] is String) {
        msg = data['message'] as String;
      }
      return ApiException(msg, statusCode: status, code: 'http_error');
    }

    return ApiException(
      e.message ?? 'Unexpected error occurred.',
      code: 'unknown',
    );
  }
}
