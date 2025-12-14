import 'package:dio/dio.dart';

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
}
