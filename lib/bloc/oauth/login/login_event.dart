import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginIdChanged extends LoginEvent {
  final String loginId;

  const LoginIdChanged(this.loginId);

  @override
  List<Object?> get props => [loginId];
}

class PinChanged extends LoginEvent {
  final String pin;

  const PinChanged(this.pin);

  @override
  List<Object?> get props => [pin];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class LoginReset extends LoginEvent {
  const LoginReset();
}
