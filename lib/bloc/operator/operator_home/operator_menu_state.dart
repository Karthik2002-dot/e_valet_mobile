import 'package:equatable/equatable.dart';

abstract class OperatorMenuState extends Equatable {
  const OperatorMenuState();

  @override
  List<Object?> get props => [];
}

class OperatorMenuInitial extends OperatorMenuState {
  const OperatorMenuInitial();
}

class OperatorMenuLogoutSuccess extends OperatorMenuState {
  final String message;
  const OperatorMenuLogoutSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OperatorMenuLogoutFailure extends OperatorMenuState {
  final String message;
  const OperatorMenuLogoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}
