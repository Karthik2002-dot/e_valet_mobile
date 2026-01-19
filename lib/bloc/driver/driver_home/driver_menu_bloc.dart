import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/logout_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class DriverMenuBloc extends Bloc<DriverMenuEvent, DriverMenuState> {
  DriverMenuBloc() : super(const DriverMenuInitial()) {
    on<DriverLogoutPressed>(_onLogoutPressed);
    on<DriverProfilePressed>((event, emit) {
      emit(const DriverMenuAction(DriverMenuActionType.profile));
    });
    on<DriverMenuReset>((event, emit) {
      emit(const DriverMenuInitial());
    });
    on<DriverHomeStarted>(_onDriverHomeStarted);
    on<DriverOnBreakToggled>(_onOnBreakToggled);
    on<DriverOnlineStatusToggled>(_onOnlineStatusToggled);
  }

  Future<void> _onLogoutPressed(
    DriverLogoutPressed event,
    Emitter<DriverMenuState> emit,
  ) async {
    emit(const DriverMenuLogoutLoading());

    try {
      final response = await LogoutApiService.logout();
      emit(DriverMenuLogoutSuccess(response));
    } on ApiException catch (e) {
      emit(DriverMenuLogoutFailure(e.message));
    } catch (e) {
      emit(DriverMenuLogoutFailure(
        TextConstants.genericError,
      ));
    }
  }

  Future<void> _onDriverHomeStarted(
    DriverHomeStarted event,
    Emitter<DriverMenuState> emit,
  ) async {
    final firstName = await TokenStorage.getFirstName() ?? '';
    final driverName =
        firstName.isNotEmpty ? firstName : TextConstants.driverFallbackName;

    emit(DriverHomeLoaded(
      driverName: driverName,
      isOnBreak: false,
      isOnline:
          false, // Start with offline, let DriverStatusBloc determine actual status
    ));
  }

  void _onOnBreakToggled(
    DriverOnBreakToggled event,
    Emitter<DriverMenuState> emit,
  ) {
    if (state is DriverHomeLoaded) {
      final currentState = state as DriverHomeLoaded;
      emit(currentState.copyWith(isOnBreak: event.isOnBreak));
    }
  }

  void _onOnlineStatusToggled(
    DriverOnlineStatusToggled event,
    Emitter<DriverMenuState> emit,
  ) {
    if (state is DriverHomeLoaded) {
      final currentState = state as DriverHomeLoaded;
      emit(currentState.copyWith(isOnline: event.isOnline));
    }
  }
}
