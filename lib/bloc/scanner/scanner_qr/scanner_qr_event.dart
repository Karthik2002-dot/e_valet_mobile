import 'package:equatable/equatable.dart';

abstract class ScannerQrEvent extends Equatable {
  const ScannerQrEvent();

  @override
  List<Object?> get props => [];
}

class ScannerQrCodeDetected extends ScannerQrEvent {
  final String rawValue;

  const ScannerQrCodeDetected(this.rawValue);

  @override
  List<Object?> get props => [rawValue];
}

class ScannerQrReset extends ScannerQrEvent {
  const ScannerQrReset();
}
