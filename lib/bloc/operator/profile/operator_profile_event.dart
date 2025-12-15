import 'package:equatable/equatable.dart';

abstract class OperatorProfileEvent extends Equatable {
  const OperatorProfileEvent();

  @override
  List<Object?> get props => [];
}

class OperatorProfileStarted extends OperatorProfileEvent {
  const OperatorProfileStarted();
}


