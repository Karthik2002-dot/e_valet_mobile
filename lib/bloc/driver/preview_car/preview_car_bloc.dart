import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/background/background_sync_service.dart';
import 'package:niloufer_valet_mobile/services/offline_sync/offline_parking_service.dart';
import 'package:niloufer_valet_mobile/models/driver/park/offline_parking_photo.dart';
import 'package:niloufer_valet_mobile/services/image/image_compression_service.dart';

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
      // Compress image before upload when a photo is provided
      String? imagePathToUse = event.imagePath;
      if (imagePathToUse != null && imagePathToUse.isNotEmpty) {
        imagePathToUse =
            await ImageCompressionService.compressImage(imagePathToUse);
      }

      // Save photo to offline storage
      final offlinePhoto = OfflineParkingPhoto(
        imagePath: imagePathToUse,
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
