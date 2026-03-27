import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/driver/session/pass_available_driver.dart';

abstract class PassAvailableDriversState extends Equatable {
  const PassAvailableDriversState();

  @override
  List<Object?> get props => [];
}

class PassAvailableDriversInitial extends PassAvailableDriversState {
  const PassAvailableDriversInitial();
}

class PassAvailableDriversLoading extends PassAvailableDriversState {
  const PassAvailableDriversLoading();
}

class PassAvailableDriversLoaded extends PassAvailableDriversState {
  final List<PassAvailableDriver> drivers;

  const PassAvailableDriversLoaded(this.drivers);

  @override
  List<Object?> get props => [drivers];
}

class PassAvailableDriversError extends PassAvailableDriversState {
  final String message;

  const PassAvailableDriversError(this.message);

  @override
  List<Object?> get props => [message];
}

/// A "pass" API call is in-flight for [driverId]; drivers list still available.
class PassingSessionToDriver extends PassAvailableDriversState {
  final String driverId;
  final List<PassAvailableDriver> drivers;

  const PassingSessionToDriver({
    required this.driverId,
    required this.drivers,
  });

  @override
  List<Object?> get props => [driverId, drivers];
}

class SessionPassedToDriver extends PassAvailableDriversState {
  final String message;

  const SessionPassedToDriver(this.message);

  @override
  List<Object?> get props => [message];
}

class PassToDriverError extends PassAvailableDriversState {
  final String message;
  final List<PassAvailableDriver> drivers;

  const PassToDriverError({required this.message, required this.drivers});

  @override
  List<Object?> get props => [message, drivers];
}
