import 'package:equatable/equatable.dart';

abstract class DriverMenuEvent extends Equatable {
  const DriverMenuEvent();

  @override
  List<Object?> get props => [];
}

class DriverLogoutPressed extends DriverMenuEvent {
  const DriverLogoutPressed();
}

class DriverProfilePressed extends DriverMenuEvent {
  const DriverProfilePressed();
}

class DriverGuidelinesPressed extends DriverMenuEvent {
  const DriverGuidelinesPressed();
}

class DriverMenuReset extends DriverMenuEvent {
  const DriverMenuReset();
}

class DriverHomeStarted extends DriverMenuEvent {
  const DriverHomeStarted();
}

class DriverPendingSessionsRefresh extends DriverMenuEvent {
  const DriverPendingSessionsRefresh();
}

class DriverOnBreakToggled extends DriverMenuEvent {
  final bool isOnBreak;

  const DriverOnBreakToggled(this.isOnBreak);

  @override
  List<Object?> get props => [isOnBreak];
}

class DriverOnlineStatusToggled extends DriverMenuEvent {
  final bool isOnline;

  const DriverOnlineStatusToggled(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}
