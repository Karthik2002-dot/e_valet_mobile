import 'package:equatable/equatable.dart';

abstract class ConfirmArrivalState extends Equatable {
  const ConfirmArrivalState();

  @override
  List<Object?> get props => [];
}

class ConfirmArrivalInitial extends ConfirmArrivalState {
  const ConfirmArrivalInitial();
}

class ConfirmArrivalLoading extends ConfirmArrivalState {
  const ConfirmArrivalLoading();
}

class ConfirmArrivalSuccess extends ConfirmArrivalState {
  final String message;

  const ConfirmArrivalSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ConfirmArrivalError extends ConfirmArrivalState {
  final String message;
  final bool shouldNavigateToHandover;

  const ConfirmArrivalError({
    required this.message,
    this.shouldNavigateToHandover = false,
  });

  @override
  List<Object?> get props => [message, shouldNavigateToHandover];
}

class ConfirmHandoverSuccess extends ConfirmArrivalState {
  final String message;

  const ConfirmHandoverSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ConfirmHandoverError extends ConfirmArrivalState {
  final String message;

  const ConfirmHandoverError({required this.message});

  @override
  List<Object?> get props => [message];
}
