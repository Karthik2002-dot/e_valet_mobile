import 'package:equatable/equatable.dart';

abstract class OperatorMenuEvent extends Equatable {
  const OperatorMenuEvent();

  @override
  List<Object?> get props => [];
}

class OperatorMenuLogoutRequested extends OperatorMenuEvent {
  const OperatorMenuLogoutRequested();
}
