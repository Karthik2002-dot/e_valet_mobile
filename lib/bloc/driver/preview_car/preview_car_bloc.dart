import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/image_API.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

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
      // Save the photo path for later upload during accept
      await TokenStorage.savePendingPhotoPath(event.imagePath);

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
