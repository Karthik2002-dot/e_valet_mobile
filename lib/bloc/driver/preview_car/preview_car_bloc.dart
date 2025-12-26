import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/image_API.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

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
      // Upload the parking photo
      await ImageApiService.uploadParkingPhoto(
        imagePath: event.imagePath,
      );

      emit(const PreviewCarSuccess());
    } on ApiException catch (e) {
      emit(PreviewCarError(message: e.message));
    } catch (e) {
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
