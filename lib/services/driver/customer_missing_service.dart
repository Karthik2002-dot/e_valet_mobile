import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/api/driver/re-park_request_api.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/re-park/repark_request.dart';
import 'package:niloufer_valet_mobile/models/driver/re-park/repark_request_response.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_camera_screen.dart';

class CustomerMissingService {
  /// Handles the customer missing workflow including API call and navigation
  static Future<void> handleCustomerMissing({
    required BuildContext context,
    required String sessionId,
    required VoidCallback onSuccess,
  }) async {
    try {
      // Create re-park request using the model
      final reparkRequest = ReparkRequest.customerNoShow();

      // Call the re-park API with the model
      final ReparkRequestResponse response =
          await ReparkApiService.requestRepark(
        sessionId: sessionId,
        request: reparkRequest,
      );

      // Check if widget is still mounted before using context
      if (!context.mounted) return;

      // Show success message
      SnackBars.showSuccessSnackBar(
        context,
        response.message.isNotEmpty
            ? response.message
            : 'Re-park request submitted successfully',
      );

      // Navigate to CarCameraScreen for re-parking
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CarCameraScreen(
            sessionId: sessionId,
            isReparking: true,
          ),
        ),
      );

      // Call success callback
      onSuccess();
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!context.mounted) return;

      if (e is ApiException) {
        SnackBars.showErrorSnackBar(context, e.message);
      } else {
        SnackBars.showErrorSnackBar(
          context,
          'Failed to submit re-park request. Please try again.',
        );
      }
    }
  }
}
