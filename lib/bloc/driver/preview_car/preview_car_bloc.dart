import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/image_API.dart';
import 'package:niloufer_valet_mobile/api/driver/re-park_api.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/park/park_request.dart';
import 'package:niloufer_valet_mobile/models/driver/re-park/repark_photo_request.dart';

class PreviewCarBloc extends Bloc<PreviewCarEvent, PreviewCarState> {
  PreviewCarBloc() : super(const PreviewCarInitial()) {
    on<SubmitPhotoRequested>(_onSubmitPhotoRequested);
    on<ResetSubmission>(_onResetSubmission);
  }

  Future<void> _onSubmitPhotoRequested(
    SubmitPhotoRequested event,
    Emitter<PreviewCarState> emit,
  ) async {
    emit(const PreviewCarSubmitting());

    try {
      if (event.isReparking) {
        // Create repark request model with GPS data
        // Scenario 1: With photo - send photo + GPS data (no parkingLocation)
        // Scenario 2: Without photo - send parkingLocation + GPS data (no photo)
        final reparkRequest = ReparkPhotoRequest(
          imagePath: event.imagePath,
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
          parkingLocation: event.parkingLocation,
        );

        // Upload re-parked car data to repark API
        await ReparkApiService.uploadReparkPhoto(
          sessionId: event.sessionId,
          request: reparkRequest,
        );
      } else {
        // Create park request model with GPS data
        // Scenario 1: With photo - send photo + GPS data (no parkingLocation)
        // Scenario 2: Without photo - send parkingLocation + GPS data (no photo)
        final parkRequest = ParkRequest(
          imagePath: event.imagePath,
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
          parkingLocation: event.parkingLocation,
        );

        // Upload parking data to park API
        await ImageApiService.uploadParkingPhoto(
          request: parkRequest,
          sessionId: event.sessionId,
        );
      }

      emit(const PreviewCarSuccess());
    } on ApiException catch (e) {
      print('❌ Photo upload failed: ${e.message}');
      emit(PreviewCarError(message: e.message));
    } catch (e) {
      print('❌ Unknown error during photo upload: $e');
      emit(const PreviewCarError(
          message: 'Failed to upload photo. Please try again.'));
    }
  }

  void _onResetSubmission(
    ResetSubmission event,
    Emitter<PreviewCarState> emit,
  ) {
    emit(const PreviewCarInitial());
  }
}
