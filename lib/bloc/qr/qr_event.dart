import 'package:equatable/equatable.dart';

abstract class QrEvent extends Equatable {
  const QrEvent();

  @override
  List<Object?> get props => [];
}

class QrCodeDetected extends QrEvent {
  final String code;

  const QrCodeDetected(this.code);

  @override
  List<Object?> get props => [code];
}

class QrResetRequested extends QrEvent {
  const QrResetRequested();
}
