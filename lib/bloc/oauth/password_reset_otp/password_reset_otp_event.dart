import 'package:equatable/equatable.dart';

abstract class PasswordResetOtpEvent extends Equatable {
  const PasswordResetOtpEvent();

  @override
  List<Object?> get props => [];
}

class PasswordResetOtpInitialized extends PasswordResetOtpEvent {
  final String phoneNumber;

  const PasswordResetOtpInitialized(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class PasswordResetOtpChanged extends PasswordResetOtpEvent {
  final String otp;

  const PasswordResetOtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

class PasswordResetOtpVerifySubmitted extends PasswordResetOtpEvent {
  const PasswordResetOtpVerifySubmitted();
}

class PasswordResetOtpNewPasswordChanged extends PasswordResetOtpEvent {
  final String password;

  const PasswordResetOtpNewPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class PasswordResetOtpResetPasswordSubmitted extends PasswordResetOtpEvent {
  const PasswordResetOtpResetPasswordSubmitted();
}
