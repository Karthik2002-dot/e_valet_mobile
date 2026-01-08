import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'operator_menu_event.dart';
import 'operator_menu_state.dart';

class OperatorMenuBloc extends Bloc<OperatorMenuEvent, OperatorMenuState> {
  OperatorMenuBloc() : super(const OperatorMenuInitial()) {
    on<OperatorMenuLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    OperatorMenuLogoutRequested event,
    Emitter<OperatorMenuState> emit,
  ) async {
    try {
      // Clear all tokens and user data
      await TokenStorage.clearAll();
      emit(const OperatorMenuLogoutSuccess('Logged out successfully'));
    } catch (e) {
      emit(OperatorMenuLogoutFailure('Logout failed: ${e.toString()}'));
    }
  }
}
