import 'package:equatable/equatable.dart';

abstract class PasswordResetOtpState extends Equatable {
  const PasswordResetOtpState();

  @override
  List<Object?> get props => [];
}

class PasswordResetOtpInitial extends PasswordResetOtpState {
  final String? storedPhone;

  const PasswordResetOtpInitial({this.storedPhone});

  @override
  List<Object?> get props => [storedPhone];
}

class PasswordResetOtpLoading extends PasswordResetOtpState {
  const PasswordResetOtpLoading();
}

class PasswordResetOtpVerifying extends PasswordResetOtpState {
  const PasswordResetOtpVerifying();
}

class PasswordResetOtpVerified extends PasswordResetOtpState {
  final String message;
  final String? resetToken;
  final String? password;
  final bool isPasswordValid;
  final String? passwordError;

  const PasswordResetOtpVerified({
    required this.message,
    this.resetToken,
    this.password,
    this.isPasswordValid = false,
    this.passwordError,
  });

  @override
  List<Object?> get props =>
      [message, resetToken, password, isPasswordValid, passwordError];
}

class PasswordResetOtpResetting extends PasswordResetOtpState {
  final String? resetToken;

  const PasswordResetOtpResetting({this.resetToken});

  @override
  List<Object?> get props => [resetToken];
}

class PasswordResetOtpResetSuccess extends PasswordResetOtpState {
  final String message;

  const PasswordResetOtpResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetOtpFailure extends PasswordResetOtpState {
  final String message;

  const PasswordResetOtpFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetOtpVerifiedWithError extends PasswordResetOtpState {
  final String message;
  final String errorMessage;
  final String? resetToken;
  final String? password;
  final bool isPasswordValid;
  final String? passwordError;

  const PasswordResetOtpVerifiedWithError({
    required this.message,
    required this.errorMessage,
    this.resetToken,
    this.password,
    this.isPasswordValid = false,
    this.passwordError,
  });

  @override
  List<Object?> get props => [
        message,
        errorMessage,
        resetToken,
        password,
        isPasswordValid,
        passwordError
      ];
}
