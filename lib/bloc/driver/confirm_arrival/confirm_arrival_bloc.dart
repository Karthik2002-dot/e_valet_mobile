import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niloufer_valet_mobile/api/driver/arrived_api.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'confirm_arrival_event.dart';
import 'confirm_arrival_state.dart';

class ConfirmArrivalBloc
    extends Bloc<ConfirmArrivalEvent, ConfirmArrivalState> {
  ConfirmArrivalBloc() : super(const ConfirmArrivalInitial()) {
    on<ConfirmArrivalStarted>(_onStarted);
    on<ConfirmArrivalRequested>(_onConfirmArrival);
  }

  Future<void> _onStarted(
    ConfirmArrivalStarted event,
    Emitter<ConfirmArrivalState> emit,
  ) async {
    emit(const ConfirmArrivalInitial());
  }

  Future<void> _onConfirmArrival(
    ConfirmArrivalRequested event,
    Emitter<ConfirmArrivalState> emit,
  ) async {
    emit(const ConfirmArrivalLoading());

    try {
      // Get stored location or fetch new one
      var locationData = await TokenStorage.getCurrentLocation();

      if (locationData == null) {
        // Request permission if needed
        LocationPermission permission = await LocationService.checkPermission();
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
            TextConstants.locationPermissionRequiredArrival,
            code: 'location_permission_denied',
          );
        }
      }

      final latitude = locationData['latitude'] as double;
      final longitude = locationData['longitude'] as double;
      final location = locationData['location'] as String;

      final response = await ArrivedApiService.confirmArrival(
        sessionId: event.sessionId,
        latitude: latitude,
        longitude: longitude,
        location: location,
      );

      // Store location for handover API (keeping for backward compatibility)
      await TokenStorage.saveArrivalLocation(
        latitude: latitude,
        longitude: longitude,
        location: location,
      );

      emit(ConfirmArrivalSuccess(message: response.message));
    } on ApiException catch (e) {
      // If session is already ARRIVED, treat it as success
      if (e.message.contains('ARRIVED') &&
          e.message.contains('expected RETRIEVING')) {
        emit(const ConfirmArrivalError(
          message: 'Arrival already confirmed. Session is ready for handover.',
          shouldNavigateToHandover: true,
        ));
      } else {
        emit(ConfirmArrivalError(message: e.message));
      }
    } catch (e) {
      emit(const ConfirmArrivalError(
        message: 'Failed to confirm arrival. Please try again.',
      ));
    }
  }
}
