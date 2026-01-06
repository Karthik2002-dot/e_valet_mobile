import 'package:equatable/equatable.dart';

abstract class ValetListEvent extends Equatable {
  const ValetListEvent();

  @override
  List<Object?> get props => [];
}

class FetchValetList extends ValetListEvent {
  final String outletId;

  const FetchValetList({required this.outletId});

  @override
  List<Object?> get props => [outletId];
}
