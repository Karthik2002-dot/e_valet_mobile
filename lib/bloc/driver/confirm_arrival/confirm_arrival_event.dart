import 'package:equatable/equatable.dart';

abstract class ConfirmArrivalEvent extends Equatable {
  const ConfirmArrivalEvent();

  @override
  List<Object?> get props => [];
}

class ConfirmArrivalStarted extends ConfirmArrivalEvent {
  const ConfirmArrivalStarted();
}

class ConfirmArrivalRequested extends ConfirmArrivalEvent {
  final String sessionId;

  const ConfirmArrivalRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
