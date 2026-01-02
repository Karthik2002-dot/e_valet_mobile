import 'package:equatable/equatable.dart';

abstract class ConfirmHandoverState extends Equatable {
  const ConfirmHandoverState();

  @override
  List<Object?> get props => [];
}

class ConfirmHandoverInitial extends ConfirmHandoverState {
  const ConfirmHandoverInitial();
}

class ConfirmHandoverLoading extends ConfirmHandoverState {
  const ConfirmHandoverLoading();
}

class ConfirmHandoverSuccess extends ConfirmHandoverState {
  final String message;

  const ConfirmHandoverSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ConfirmHandoverError extends ConfirmHandoverState {
  final String message;

  const ConfirmHandoverError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ConfirmHandoverValidationError extends ConfirmHandoverState {
  final String message;

  const ConfirmHandoverValidationError({required this.message});

  factory ConfirmHandoverValidationError.codeRequired() {
    return const ConfirmHandoverValidationError(
      message: 'Please enter the 2-digit code',
    );
  }

  @override
  List<Object?> get props => [message];
}
