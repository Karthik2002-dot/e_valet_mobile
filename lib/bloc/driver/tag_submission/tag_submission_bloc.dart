import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/session_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/session/checkin_request.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class TagSubmissionBloc extends Bloc<TagSubmissionEvent, TagSubmissionState> {
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
      final request = CheckinRequest(
        outletId: event.qrData.outletId,
        cardNumber: event.qrData.cardNumber,
        isManualRequest: false,
      );

      final response = await SessionApiService.checkin(request);

      // Store session ID in Hive
      if (response.sessionId.isNotEmpty) {
        await TokenStorage.saveSessionId(response.sessionId);
      }

      emit(TagSubmissionSuccess(response.message));
    } on ApiException catch (e) {
      if (e.code == 'session_expired') {
        emit(const TagSubmissionSessionExpired());
      } else {
        emit(TagSubmissionError(e.message));
      }
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
      final request = CheckinRequest(
        outletId: event.outletId,
        cardNumber: event.cardNumber,
        isManualRequest: true,
      );

      final response = await SessionApiService.checkin(request);

      // Store session ID in Hive
      if (response.sessionId.isNotEmpty) {
        await TokenStorage.saveSessionId(response.sessionId);
      }

      emit(TagSubmissionSuccess(response.message));
    } on ApiException catch (e) {
      if (e.code == 'session_expired') {
        emit(const TagSubmissionSessionExpired());
      } else {
        emit(TagSubmissionError(e.message));
      }
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
