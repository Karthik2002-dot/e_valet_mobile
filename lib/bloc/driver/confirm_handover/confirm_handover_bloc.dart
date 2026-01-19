import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niloufer_valet_mobile/api/driver/handover_api.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'confirm_handover_event.dart';
import 'confirm_handover_state.dart';

class ConfirmHandoverBloc
    extends Bloc<ConfirmHandoverEvent, ConfirmHandoverState> {
  ConfirmHandoverBloc() : super(const ConfirmHandoverInitial()) {
    on<ConfirmHandoverStarted>(_onStarted);
    on<ConfirmHandoverRequested>(_onConfirmHandover);
  }

  Future<void> _onStarted(
    ConfirmHandoverStarted event,
    Emitter<ConfirmHandoverState> emit,
  ) async {
    emit(const ConfirmHandoverInitial());
  }

  Future<void> _onConfirmHandover(
    ConfirmHandoverRequested event,
    Emitter<ConfirmHandoverState> emit,
  ) async {
    emit(const ConfirmHandoverLoading());

    try {
      // Get stored current location (used for accept, arrived, handover)
      var locationData = await TokenStorage.getCurrentLocation();

      if (locationData == null) {
        // Fallback: Try arrival location for backward compatibility
        locationData = await TokenStorage.getArrivalLocation();

        if (locationData == null) {
          // Last resort: Get current location
          // Request permission if needed
          LocationPermission permission =
              await LocationService.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await LocationService.requestPermission();
          }

          if (permission != LocationPermission.denied &&
              permission != LocationPermission.deniedForever) {
            final position = await LocationService.getCurrentLocation();
            final latitude = position.latitude;
            final longitude = position.longitude;
            final location =
                '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

            locationData = {
              'latitude': latitude,
              'longitude': longitude,
              'location': location,
            };

            // Save for future use
            await TokenStorage.saveCurrentLocation(
              latitude: latitude,
              longitude: longitude,
              location: location,
            );
          } else {
            throw ApiException(
              TextConstants.locationPermissionRequiredHandover,
              code: 'location_permission_denied',
            );
          }
        }
      }

      final latitude = locationData['latitude'] as double;
      final longitude = locationData['longitude'] as double;
      final accuracy = locationData['accuracy'] as double;

      // Call handover API
      final response = await HandoverApiService.confirmHandover(
        sessionId: event.sessionId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );

      emit(ConfirmHandoverSuccess(message: response.message));
    } on ApiException catch (e) {
      emit(ConfirmHandoverError(message: e.message));
    } catch (e) {
      emit(ConfirmHandoverError(
        message: TextConstants.genericError,
      ));
    }
  }
}
