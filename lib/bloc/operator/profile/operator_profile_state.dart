import 'package:equatable/equatable.dart';

abstract class OperatorProfileState extends Equatable {
  const OperatorProfileState();

  @override
  List<Object?> get props => [];
}

class OperatorProfileInitial extends OperatorProfileState {
  const OperatorProfileInitial();
}

class OperatorProfileLoading extends OperatorProfileState {
  const OperatorProfileLoading();
}

class OperatorProfileLoaded extends OperatorProfileState {
  const OperatorProfileLoaded();
}

class OperatorProfileError extends OperatorProfileState {
  final String message;

  const OperatorProfileError(this.message);

  @override
  List<Object?> get props => [message];
}


