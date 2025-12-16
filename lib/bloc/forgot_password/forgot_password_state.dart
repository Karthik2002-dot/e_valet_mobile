import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  final String phoneNumber;

  const ForgotPasswordSuccess(this.message, this.phoneNumber);

  @override
  List<Object?> get props => [message, phoneNumber];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String message;

  const ForgotPasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}
