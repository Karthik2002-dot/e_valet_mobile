import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/api/core/base_dio_service.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_cards/card_assignments_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

/// GET/POST /api/v1/operators/card-assignments
class CardAssignmentsApiService {
  CardAssignmentsApiService._();

  /// Lists card assignments for an outlet (query: outletId).
  static Future<CardAssignmentsResponse> getCardAssignments({
    required String outletId,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }

    final base = BaseDioService(
      ApiConfig.valetBaseUrl,
      ApiConfig.authorizedHeaders(accessToken),
    );

    final response = await base.get(
      '/operators/card-assignments',
      queryParameters: {'outletId': outletId},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return CardAssignmentsResponse.fromJson(data);
    }
    throw ApiException(
      'Unexpected card-assignments response',
      code: 'card_assignments_bad_response',
      statusCode: response.statusCode,
    );
  }

  /// Assigns physical card IDs to a driver for an outlet.
  static Future<void> submitCardAssignments({
    required String outletId,
    required String driverUserId,
    required List<int> cardIds,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        'Access token not found. Please login again.',
        code: 'no_token',
      );
    }

    final base = BaseDioService(
      ApiConfig.valetBaseUrl,
      ApiConfig.authorizedHeaders(accessToken),
    );

    final outletIdNum = int.tryParse(outletId.trim()) ?? 0;

    await base.post(
      '/operators/card-assignments',
      data: <String, dynamic>{
        'cardIds': cardIds,
        'driverUserId': driverUserId,
        'outletId': outletIdNum,
      },
    );
  }
}
