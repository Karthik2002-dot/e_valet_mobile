import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

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
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = {...defaultHeaders, ...?headers};

    try {
      final response = await http
          .post(uri, headers: mergedHeaders, body: jsonEncode(body))
          .timeout(timeout);
      _throwIfHttpError(response);
      return response;
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

  Future<http.Response> getJson(
    String path, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = {...defaultHeaders, ...?headers};

    try {
      final response =
          await http.get(uri, headers: mergedHeaders).timeout(timeout);
      _throwIfHttpError(response);
      return response;
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
          final messageList = message
              .whereType<String>()
              .where((m) => m.isNotEmpty)
              .toList();
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
