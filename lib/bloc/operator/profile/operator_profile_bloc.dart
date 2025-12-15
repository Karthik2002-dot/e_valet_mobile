import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/profile/operator_profile_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/profile/operator_profile_state.dart';

class OperatorProfileBloc
    extends Bloc<OperatorProfileEvent, OperatorProfileState> {
  OperatorProfileBloc() : super(const OperatorProfileInitial()) {
    on<OperatorProfileStarted>(_onStarted);
  }

  Future<void> _onStarted(
    OperatorProfileStarted event,
    Emitter<OperatorProfileState> emit,
  ) async {
    emit(const OperatorProfileLoading());

    try {
      // TODO: load operator profile from API when available
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(const OperatorProfileLoaded());
    } catch (_) {
      emit(const OperatorProfileError('Failed to load profile'));
    }
  }
}


