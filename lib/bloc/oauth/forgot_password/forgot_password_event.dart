import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordPhoneChanged extends ForgotPasswordEvent {
  final String phoneNumber;

  const ForgotPasswordPhoneChanged(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  const ForgotPasswordSubmitted();
}

class ForgotPasswordReset extends ForgotPasswordEvent {
  const ForgotPasswordReset();
}
