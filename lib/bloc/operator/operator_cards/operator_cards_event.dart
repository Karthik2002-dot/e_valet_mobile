import 'package:equatable/equatable.dart';

abstract class OperatorCardsEvent extends Equatable {
  const OperatorCardsEvent();

  @override
  List<Object?> get props => [];
}

class OperatorCardsLoadRequested extends OperatorCardsEvent {
  const OperatorCardsLoadRequested();
}

class OperatorCardsRefreshRequested extends OperatorCardsEvent {
  const OperatorCardsRefreshRequested();
}

class OperatorCardsSearchQueryChanged extends OperatorCardsEvent {
  final String query;

  const OperatorCardsSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
