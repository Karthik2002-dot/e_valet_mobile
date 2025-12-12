import 'package:equatable/equatable.dart';

abstract class QrEvent extends Equatable {
  const QrEvent();

  @override
  List<Object?> get props => [];
}

class QrStatusToggled extends QrEvent {
  final bool isOnline;

  const QrStatusToggled(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class QrBreakToggled extends QrEvent {
  final bool isOnBreak;

  const QrBreakToggled(this.isOnBreak);

  @override
  List<Object?> get props => [isOnBreak];
}

class QrResetRequested extends QrEvent {
  const QrResetRequested();
}
