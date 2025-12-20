import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/driver/driver_status.dart';

abstract class DriverStatusState extends Equatable {
  const DriverStatusState();

  @override
  List<Object?> get props => [];
}

class DriverStatusInitial extends DriverStatusState {
  const DriverStatusInitial();
}

class DriverStatusLoading extends DriverStatusState {
  const DriverStatusLoading();
}

class DriverStatusLoaded extends DriverStatusState {
  final DriverStatus status;

  const DriverStatusLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

class DriverStatusError extends DriverStatusState {
  final String message;

  const DriverStatusError(this.message);

  @override
  List<Object?> get props => [message];
}
