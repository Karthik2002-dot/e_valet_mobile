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

  const PasswordResetOtpVerified({
    required this.message,
    this.resetToken,
  });

  @override
  List<Object?> get props => [message, resetToken];
}

class PasswordResetOtpResetting extends PasswordResetOtpState {
  const PasswordResetOtpResetting();
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
