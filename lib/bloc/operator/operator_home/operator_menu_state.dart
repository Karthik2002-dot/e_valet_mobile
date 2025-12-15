import 'package:equatable/equatable.dart';

abstract class OperatorMenuState extends Equatable {
  const OperatorMenuState();

  @override
  List<Object?> get props => [];
}

class OperatorMenuInitial extends OperatorMenuState {
  const OperatorMenuInitial();
}

enum OperatorMenuActionType { logout, profile }

class OperatorMenuAction extends OperatorMenuState {
  final OperatorMenuActionType action;

  const OperatorMenuAction(this.action);

  @override
  List<Object?> get props => [action];
}


