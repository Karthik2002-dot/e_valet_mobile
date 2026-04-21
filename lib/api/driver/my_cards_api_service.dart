import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/cards/my_cards_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class MyCardsApiService {
  MyCardsApiService._();

  static String get _baseUrl => ApiConfig.valetBaseUrl;

  static Future<MyCardsResponse> getMyCards() async {
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
      final response = await base.get('/drivers/my-cards');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ApiException(
          'Unexpected my cards response.',
          code: 'bad_my_cards_response',
        );
      }
      return MyCardsResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Failed to load assigned cards. Please try again.',
        code: 'unknown_error',
      );
    }
  }
}
