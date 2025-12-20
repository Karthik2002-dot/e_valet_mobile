import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

class TagSubmissionBloc
    extends Bloc<TagSubmissionEvent, TagSubmissionState> {
  TagSubmissionBloc() : super(const TagSubmissionInitial()) {
    on<QrCodeSubmitted>(_onQrCodeSubmitted);
    on<TagNumberSubmitted>(_onTagNumberSubmitted);
    on<TagSubmissionReset>(_onReset);
  }

  Future<void> _onQrCodeSubmitted(
    QrCodeSubmitted event,
    Emitter<TagSubmissionState> emit,
  ) async {
    emit(const TagSubmissionLoading());

    try {
      // TODO: Call API service to submit QR code
      // Example: await ParkingApiService.submitQrCode(event.qrCode);
      
      // Simulate API call for now
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(TagSubmissionSuccess('QR code submitted successfully'));
    } on ApiException catch (e) {
      emit(TagSubmissionError(e.message));
    } catch (e) {
      emit(TagSubmissionError(
        'Failed to submit QR code. Please try again.',
      ));
    }
  }

  Future<void> _onTagNumberSubmitted(
    TagNumberSubmitted event,
    Emitter<TagSubmissionState> emit,
  ) async {
    emit(const TagSubmissionLoading());

    try {
      // TODO: Call API service to submit tag number
      // Example: await ParkingApiService.submitTagNumber(event.tagNumber);
      
      // Simulate API call for now
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(TagSubmissionSuccess('Tag number submitted successfully'));
    } on ApiException catch (e) {
      emit(TagSubmissionError(e.message));
    } catch (e) {
      emit(TagSubmissionError(
        'Failed to submit tag number. Please try again.',
      ));
    }
  }

  void _onReset(
    TagSubmissionReset event,
    Emitter<TagSubmissionState> emit,
  ) {
    emit(const TagSubmissionInitial());
  }
}

