import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/profile_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/profile/profile_event.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/profile/profile_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<ProfileStarted>(_onStarted);
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final profile = await ProfileApiService.getProfile();
      emit(ProfileLoaded(profile));
    } on ApiException catch (e) {
      emit(ProfileError(e.message));
    } catch (_) {
      emit(const ProfileError('Failed to load profile'));
    }
  }
}
