import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/oauth/profile.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final Profile profile;

  const LoginSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
