import 'package:equatable/equatable.dart';

abstract class OperatorMenuEvent extends Equatable {
  const OperatorMenuEvent();

  @override
  List<Object?> get props => [];
}

class OperatorLogoutPressed extends OperatorMenuEvent {
  const OperatorLogoutPressed();
}

class OperatorProfilePressed extends OperatorMenuEvent {
  const OperatorProfilePressed();
}

class OperatorMenuReset extends OperatorMenuEvent {
  const OperatorMenuReset();
}

class OperatorHomeStarted extends OperatorMenuEvent {
  const OperatorHomeStarted();
}

class OperatorOnBreakToggled extends OperatorMenuEvent {
  final bool isOnBreak;

  const OperatorOnBreakToggled(this.isOnBreak);

  @override
  List<Object?> get props => [isOnBreak];
}

class OperatorOnlineStatusToggled extends OperatorMenuEvent {
  final bool isOnline;

  const OperatorOnlineStatusToggled(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}
