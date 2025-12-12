import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

import 'qr_event.dart';
import 'qr_state.dart';

export 'qr_event.dart';
export 'qr_state.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  QrBloc() : super(QrState.initial()) {
    on<QrStatusToggled>(_onStatusToggled);
    on<QrBreakToggled>(_onBreakToggled);
    on<QrResetRequested>(_onResetRequested);
  }

  Future<void> _onStatusToggled(
    QrStatusToggled event,
    Emitter<QrState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    await Future.delayed(const Duration(milliseconds: 250));
    emit(
      state.copyWith(
        isLoading: false,
        isOnline: event.isOnline,
        message: event.isOnline
            ? TextConstants.statusOnlineMessage
            : TextConstants.statusOfflineMessage,
      ),
    );
  }

  Future<void> _onBreakToggled(
    QrBreakToggled event,
    Emitter<QrState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    await Future.delayed(const Duration(milliseconds: 250));
    emit(
      state.copyWith(
        isLoading: false,
        isOnBreak: event.isOnBreak,
        message: event.isOnBreak
            ? TextConstants.breakEnabledMessage
            : TextConstants.breakDisabledMessage,
      ),
    );
  }

  void _onResetRequested(
    QrResetRequested event,
    Emitter<QrState> emit,
  ) {
    emit(QrState.initial());
  }
}
