import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/oauth/logout_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_menu/scanner_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_menu/scanner_menu_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class ScannerMenuBloc extends Bloc<ScannerMenuEvent, ScannerMenuState> {
  ScannerMenuBloc() : super(const ScannerMenuInitial()) {
    on<ScannerLogoutPressed>(_onLogoutPressed);
    on<ScannerProfilePressed>((event, emit) {
      emit(const ScannerMenuAction(ScannerMenuActionType.profile));
    });
    on<ScannerMenuReset>((event, emit) {
      emit(const ScannerMenuInitial());
    });
  }

  Future<void> _onLogoutPressed(
    ScannerLogoutPressed event,
    Emitter<ScannerMenuState> emit,
  ) async {
    emit(const ScannerMenuLogoutLoading());
    try {
      final response = await LogoutApiService.logout();
      emit(ScannerMenuLogoutSuccess(response));
    } on ApiException catch (e) {
      emit(ScannerMenuLogoutFailure(e.message));
    } catch (e) {
      emit(const ScannerMenuLogoutFailure(TextConstants.genericError));
    }
  }
}
