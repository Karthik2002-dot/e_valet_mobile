import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/oauth/logout_response.dart';

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

class OperatorMenuLogoutLoading extends OperatorMenuState {
  const OperatorMenuLogoutLoading();
}

class OperatorMenuLogoutSuccess extends OperatorMenuState {
  final LogoutResponse response;

  const OperatorMenuLogoutSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class OperatorMenuLogoutFailure extends OperatorMenuState {
  final String message;

  const OperatorMenuLogoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}
