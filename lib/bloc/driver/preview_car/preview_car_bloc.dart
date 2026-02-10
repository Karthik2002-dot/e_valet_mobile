import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/image_API.dart';
import 'package:niloufer_valet_mobile/api/driver/re-park_api.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_state.dart';

import 'package:niloufer_valet_mobile/models/driver/park/park_request.dart';
import 'package:niloufer_valet_mobile/models/driver/re-park/repark_photo_request.dart';
import 'package:niloufer_valet_mobile/services/background/background_sync_service.dart';
import 'package:niloufer_valet_mobile/services/offline_sync/offline_parking_service.dart';
import 'package:niloufer_valet_mobile/models/driver/park/offline_parking_photo.dart';
import 'package:niloufer_valet_mobile/services/image/image_compression_service.dart';
import 'package:flutter/foundation.dart';

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

    String? imagePathToUse = event.imagePath;

    try {
      // Compress image before upload when a photo is provided
      if (imagePathToUse != null && imagePathToUse.isNotEmpty) {
        imagePathToUse =
            await ImageCompressionService.compressImage(imagePathToUse);
      }

      // Try online upload first
      if (event.isReparking) {
        final request = ReparkPhotoRequest(
          imagePath: imagePathToUse,
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
          parkingLocation: event.parkingLocation,
        );
        await ReparkApiService.uploadReparkPhoto(
          request: request,
          sessionId: event.sessionId,
        );
      } else {
        final request = ParkRequest(
          imagePath: imagePathToUse,
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
          parkingLocation: event.parkingLocation,
        );
        await ImageApiService.uploadParkingPhoto(
          request: request,
          sessionId: event.sessionId,
        );
      }

      emit(const PreviewCarSuccess());
    } catch (e) {
      debugPrint('❌ Online upload failed, falling back to offline storage: $e');

      try {
        // Save photo to offline storage
        final offlinePhoto = OfflineParkingPhoto(
          imagePath: imagePathToUse, // Use the compressed path
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
          parkingLocation: event.parkingLocation,
          sessionId: event.sessionId,
          isReparking: event.isReparking,
          timestamp: DateTime.now().toIso8601String(),
        );

        await OfflineParkingService.saveParkingPhoto(offlinePhoto);

        // Trigger background sync
        await BackgroundSyncService.triggerSync();

        // Emit success immediately
        emit(const PreviewCarSuccess());
      } catch (dbError) {
        debugPrint('❌ Failed to save offline photo: $dbError');
        emit(const PreviewCarError(
            message: 'Failed to save photo. Please try again.'));
      }
    }
  }

  void _onResetSubmission(
    ResetSubmission event,
    Emitter<PreviewCarState> emit,
  ) {
    emit(const PreviewCarInitial());
  }
}
