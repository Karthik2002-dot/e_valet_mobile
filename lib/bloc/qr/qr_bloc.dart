import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_event.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_state.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  QrBloc() : super(const QrState()) {
    on<QrCodeDetected>(_onQrCodeDetected);
    on<QrResetRequested>(_onResetRequested);
  }

  Future<void> _onQrCodeDetected(
    QrCodeDetected event,
    Emitter<QrState> emit,
  ) async {
    // If already processing, ignore new scans
    if (state.isProcessing) return;

    emit(state.copyWith(
      scannedCode: event.code,
      isProcessing: true,
      successMessage: null,
      errorMessage: null,
    ));

    try {
      // TODO: Plug in real processing/API call here
      await Future.delayed(const Duration(milliseconds: 300));

      emit(state.copyWith(
        scannedCode: event.code,
        isProcessing: false,
        successMessage: TextConstants.qrCodeScannedSuccessfully,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        scannedCode: event.code,
        isProcessing: false,
        successMessage: null,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetRequested(
    QrResetRequested event,
    Emitter<QrState> emit,
  ) {
    emit(const QrState());
  }
}
