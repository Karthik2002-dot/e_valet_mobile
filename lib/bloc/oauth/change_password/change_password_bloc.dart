import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/password_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/change_password/change_password_event.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/change_password/change_password_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/oauth/change_password_request.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc() : super(const ChangePasswordState()) {
    on<ChangePasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    // Trim all inputs
    final oldPassword = event.oldPassword.trim();
    final newPassword = event.newPassword.trim();
    final confirmPassword = event.confirmPassword.trim();

    // Validation: All fields required
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'All fields are required.',
        ),
      );
      return;
    }

    // Validation: Password minimum length
    const minPasswordLength = 6;
    if (oldPassword.length < minPasswordLength) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage:
              'Current password must be at least $minPasswordLength characters.',
        ),
      );
      return;
    }

    if (newPassword.length < minPasswordLength) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage:
              'New password must be at least $minPasswordLength characters.',
        ),
      );
      return;
    }

    // Validation: New password and confirm password must match
    if (newPassword != confirmPassword) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'New password and confirm password must match.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: null,
      ),
    );

    try {
      final request = ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      await PasswordApiService.changePassword(request);

      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          errorMessage: null,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Failed to change password. Please try again.',
        ),
      );
    }
  }
}
