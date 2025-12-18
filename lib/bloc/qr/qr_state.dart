import 'package:equatable/equatable.dart';

class QrState extends Equatable {
  final String? scannedCode;
  final bool isProcessing;
  final String? successMessage;
  final String? errorMessage;

  const QrState({
    this.scannedCode,
    this.isProcessing = false,
    this.successMessage,
    this.errorMessage,
  });

  QrState copyWith({
    String? scannedCode,
    bool? isProcessing,
    String? successMessage,
    String? errorMessage,
  }) {
    return QrState(
      scannedCode: scannedCode ?? this.scannedCode,
      isProcessing: isProcessing ?? this.isProcessing,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        scannedCode,
        isProcessing,
        successMessage,
        errorMessage,
      ];
}
