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


