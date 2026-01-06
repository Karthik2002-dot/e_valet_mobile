import 'dart:convert';
import 'package:niloufer_valet_mobile/api/core/api_config.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_valet/valet_kpis_response.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:http/http.dart' as http;

class ValetKpisApiService {
  /// Get valet KPIs for a specific outlet
  static Future<ValetKpisResponse> getValetKpis({
    required String outletId,
  }) async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found');
      }

      final uri = Uri.parse(
        '${ApiConfig.valetBaseUrl}/operators/valets/kpis',
      ).replace(queryParameters: {'outletId': outletId});

      final response = await http.get(
        uri,
        headers: ApiConfig.authorizedHeaders(accessToken),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ValetKpisResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load valet KPIs: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching valet KPIs: $e');
    }
  }
}
