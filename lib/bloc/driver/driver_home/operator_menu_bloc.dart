import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/logout_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/operator_menu_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class OperatorMenuBloc extends Bloc<OperatorMenuEvent, OperatorMenuState> {
  OperatorMenuBloc() : super(const OperatorMenuInitial()) {
    on<OperatorLogoutPressed>(_onLogoutPressed);
    on<OperatorProfilePressed>((event, emit) {
      emit(const OperatorMenuAction(OperatorMenuActionType.profile));
    });
    on<OperatorMenuReset>((event, emit) {
      emit(const OperatorMenuInitial());
    });
    on<OperatorHomeStarted>(_onOperatorHomeStarted);
    on<OperatorOnBreakToggled>(_onOnBreakToggled);
    on<OperatorOnlineStatusToggled>(_onOnlineStatusToggled);
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
        TextConstants.genericError,
      ));
    }
  }

  Future<void> _onOperatorHomeStarted(
    OperatorHomeStarted event,
    Emitter<OperatorMenuState> emit,
  ) async {
    final firstName = await TokenStorage.getFirstName() ?? '';
    final operatorName =
        firstName.isNotEmpty ? firstName : TextConstants.operatorFallbackName;

    emit(OperatorHomeLoaded(
      operatorName: operatorName,
      isOnBreak: false,
      isOnline: true,
    ));
  }

  void _onOnBreakToggled(
    OperatorOnBreakToggled event,
    Emitter<OperatorMenuState> emit,
  ) {
    if (state is OperatorHomeLoaded) {
      final currentState = state as OperatorHomeLoaded;
      emit(currentState.copyWith(isOnBreak: event.isOnBreak));
    }
  }

  void _onOnlineStatusToggled(
    OperatorOnlineStatusToggled event,
    Emitter<OperatorMenuState> emit,
  ) {
    if (state is OperatorHomeLoaded) {
      final currentState = state as OperatorHomeLoaded;
      emit(currentState.copyWith(isOnline: event.isOnline));
    }
  }
}
