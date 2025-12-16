import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/logout_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';

class OperatorMenuBloc extends Bloc<OperatorMenuEvent, OperatorMenuState> {
  OperatorMenuBloc() : super(const OperatorMenuInitial()) {
    on<OperatorLogoutPressed>(_onLogoutPressed);
    on<OperatorProfilePressed>((event, emit) {
      emit(const OperatorMenuAction(OperatorMenuActionType.profile));
    });
    on<OperatorMenuReset>((event, emit) {
      emit(const OperatorMenuInitial());
    });
  }

  Future<void> _onLogoutPressed(
    OperatorLogoutPressed event,
    Emitter<OperatorMenuState> emit,
  ) async {
    emit(const OperatorMenuLogoutLoading());

    try {
      final response = await LogoutApiService.logout();
      emit(OperatorMenuLogoutSuccess(response));
    } on ApiException catch (e) {
      emit(OperatorMenuLogoutFailure(e.message));
    } catch (e) {
      emit(OperatorMenuLogoutFailure(
        'Something went wrong. Please try again.',
      ));
    }
  }
}


