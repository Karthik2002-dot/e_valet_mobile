import 'package:equatable/equatable.dart';

abstract class ConnectivityState extends Equatable {
  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {}

/// No usable network: no interface, or interface present but DNS/reachability probe failed.
class ConnectivityUnavailable extends ConnectivityState {}
