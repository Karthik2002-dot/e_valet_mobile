import 'package:equatable/equatable.dart';

abstract class DriverStatusEvent extends Equatable {
  const DriverStatusEvent();

  @override
  List<Object?> get props => [];
}

class DriverStatusStarted extends DriverStatusEvent {
  const DriverStatusStarted();
}

class DriverStatusRefreshed extends DriverStatusEvent {
  const DriverStatusRefreshed();
}

class DriverStatusUpdated extends DriverStatusEvent {
  final String status; // "ONLINE" or "OFFLINE"

  const DriverStatusUpdated(this.status);

  @override
  List<Object?> get props => [status];
}
