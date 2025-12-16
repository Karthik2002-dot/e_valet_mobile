import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/profile_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/operator/profile/operator_profile_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/profile/operator_profile_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

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
      final profile = await ProfileApiService.getProfile();
      emit(OperatorProfileLoaded(profile));
    } on ApiException catch (e) {
      emit(OperatorProfileError(e.message));
    } catch (_) {
      emit(const OperatorProfileError('Failed to load profile'));
    }
  }
}
