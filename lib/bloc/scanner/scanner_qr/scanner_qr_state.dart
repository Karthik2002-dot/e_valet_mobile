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

/// User scanned the valet (JSON) QR instead of the customer WhatsApp QR.
/// UI should show the message and close the dialog.
class ScannerQrValetCardScanned extends ScannerQrState {
  final String message;

  const ScannerQrValetCardScanned(this.message);

  @override
  List<Object?> get props => [message];
}
