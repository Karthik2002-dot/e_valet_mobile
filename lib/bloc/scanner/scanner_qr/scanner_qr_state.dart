import 'package:equatable/equatable.dart';

abstract class ScannerQrState extends Equatable {
  const ScannerQrState();

  @override
  List<Object?> get props => [];
}

class ScannerQrInitial extends ScannerQrState {
  const ScannerQrInitial();
}

class ScannerQrProcessing extends ScannerQrState {
  const ScannerQrProcessing();
}

class ScannerQrSuccess extends ScannerQrState {
  final String message;

  const ScannerQrSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ScannerQrError extends ScannerQrState {
  final String message;

  const ScannerQrError(this.message);

  @override
  List<Object?> get props => [message];
}

class ScannerQrInvalidQr extends ScannerQrState {
  final String message;

  const ScannerQrInvalidQr(this.message);

  @override
  List<Object?> get props => [message];
}
