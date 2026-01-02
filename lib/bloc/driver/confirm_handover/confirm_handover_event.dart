import 'package:equatable/equatable.dart';

abstract class ConfirmHandoverEvent extends Equatable {
  const ConfirmHandoverEvent();

  @override
  List<Object?> get props => [];
}

class ConfirmHandoverStarted extends ConfirmHandoverEvent {
  const ConfirmHandoverStarted();
}

class ConfirmHandoverRequested extends ConfirmHandoverEvent {
  final String sessionId;
  final String code;

  const ConfirmHandoverRequested({
    required this.sessionId,
    required this.code,
  });

  @override
  List<Object?> get props => [sessionId, code];
}
