import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/driver/qr/qr_data.dart';

class QrState extends Equatable {
  final String? scannedCode;
  final QrData? qrData;
  final bool isProcessing;
  final String? successMessage;
  final String? errorMessage;
  final bool shouldStopScanner;

  const QrState({
    this.scannedCode,
    this.qrData,
    this.isProcessing = false,
    this.successMessage,
    this.errorMessage,
    this.shouldStopScanner = false,
  });

  QrState copyWith({
    String? scannedCode,
    QrData? qrData,
    bool? isProcessing,
    String? successMessage,
    String? errorMessage,
    bool? shouldStopScanner,
  }) {
    return QrState(
      scannedCode: scannedCode ?? this.scannedCode,
      qrData: qrData ?? this.qrData,
      isProcessing: isProcessing ?? this.isProcessing,
      successMessage: successMessage,
      errorMessage: errorMessage,
      shouldStopScanner: shouldStopScanner ?? this.shouldStopScanner,
    );
  }

  @override
  List<Object?> get props => [
        scannedCode,
        qrData,
        isProcessing,
        successMessage,
        errorMessage,
        shouldStopScanner,
      ];
}
