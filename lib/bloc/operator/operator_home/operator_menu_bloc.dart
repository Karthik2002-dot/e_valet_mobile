import 'package:flutter_bloc/flutter_bloc.dart';
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
      // TODO: implement actual logout API calls / token clearing
      emit(const OperatorMenuLogoutSuccess('Logged out successfully'));
    } catch (_) {
      emit(const OperatorMenuLogoutFailure('Logout failed'));
    }
  }
}
