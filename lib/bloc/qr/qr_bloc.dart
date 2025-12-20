import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_event.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_state.dart';
import 'package:niloufer_valet_mobile/models/driver/qr/qr_data.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  QrBloc() : super(const QrState()) {
    on<QrCodeDetected>(_onQrCodeDetected);
    on<QrResetRequested>(_onResetRequested);
  }

  Future<void> _onQrCodeDetected(
    QrCodeDetected event,
    Emitter<QrState> emit,
  ) async {
    // If already processing or scanner is stopped, ignore new scans
    if (state.isProcessing || state.shouldStopScanner) return;

    emit(state.copyWith(
      scannedCode: event.code,
      qrData: null,
      isProcessing: true,
      successMessage: null,
      errorMessage: null,
      shouldStopScanner: false,
    ));

    try {
      // Parse JSON from QR code
      final jsonData = jsonDecode(event.code) as Map<String, dynamic>;
      final qrData = QrData.fromJson(jsonData);

      // Show success message and stop scanner after parsing
      emit(state.copyWith(
        scannedCode: event.code,
        qrData: qrData,
        isProcessing: false,
        successMessage: 'Scanned Success',
        errorMessage: null,
        shouldStopScanner:
            true, // Stop scanner when data is successfully parsed
      ));
    } catch (e) {
      // On error, also stop scanner and show error message
      emit(state.copyWith(
        scannedCode: event.code,
        qrData: null,
        isProcessing: false,
        successMessage: null,
        errorMessage: 'Invalid QR code format. Please scan again.',
        shouldStopScanner: true, // Stop scanner on error too
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
