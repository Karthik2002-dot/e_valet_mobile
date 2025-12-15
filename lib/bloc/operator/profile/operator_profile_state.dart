import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/oauth/profile.dart';

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
  final Profile profile;

  const OperatorProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class OperatorProfileError extends OperatorProfileState {
  final String message;

  const OperatorProfileError(this.message);

  @override
  List<Object?> get props => [message];
}


