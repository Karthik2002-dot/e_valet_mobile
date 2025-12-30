import 'package:flutter_bloc/flutter_bloc.dart';
import 'retrival_request_event.dart';
import 'retrival_requesy_state.dart';
import 'package:niloufer_valet_mobile/api/driver/assigned_sessions_api_service.dart';

class RetrivalRequestBloc
    extends Bloc<RetrivalRequestEvent, RetrivalRequestState> {
  RetrivalRequestBloc() : super(const RetrivalRequestInitial()) {
    on<FetchRetrivalRequests>(_onFetch);
    on<AcceptRetrivalRequest>(_onAccept);
  }

  Future<void> _onFetch(
    FetchRetrivalRequests event,
    Emitter<RetrivalRequestState> emit,
  ) async {
    emit(const RetrivalRequestLoading());
    try {
      final sessions = await AssignedSessionsApiService.fetchAssignedSessions();
      emit(RetrivalRequestLoaded(sessions));
    } catch (e) {
      final msg = (e is Exception) ? e.toString() : 'Failed to load requests';
      emit(RetrivalRequestError(msg));
    }
  }

  Future<void> _onAccept(
    AcceptRetrivalRequest event,
    Emitter<RetrivalRequestState> emit,
  ) async {
    // Placeholder: acceptance API may not be available in this repo.
    // For now, emit accepted state immediately.
    emit(RetrivalRequestAccepted('Request accepted'));
  }
}
