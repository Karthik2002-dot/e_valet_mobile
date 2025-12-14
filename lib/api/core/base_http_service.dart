import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  }) {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = {...defaultHeaders, ...?headers};
    return http
        .post(uri, headers: mergedHeaders, body: jsonEncode(body))
        .timeout(timeout);
  }

  Future<http.Response> getJson(
    String path, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = {...defaultHeaders, ...?headers};
    return http.get(uri, headers: mergedHeaders).timeout(timeout);
  }
}
