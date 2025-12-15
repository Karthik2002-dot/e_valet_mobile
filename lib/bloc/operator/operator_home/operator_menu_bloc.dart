import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_state.dart';

class OperatorMenuBloc extends Bloc<OperatorMenuEvent, OperatorMenuState> {
  OperatorMenuBloc() : super(const OperatorMenuInitial()) {
    on<OperatorLogoutPressed>((event, emit) {
      emit(const OperatorMenuAction(OperatorMenuActionType.logout));
    });
    on<OperatorProfilePressed>((event, emit) {
      emit(const OperatorMenuAction(OperatorMenuActionType.profile));
    });
    on<OperatorMenuReset>((event, emit) {
      emit(const OperatorMenuInitial());
    });
  }
}


