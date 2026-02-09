import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityEvent {}

class CheckConnectivity extends ConnectivityEvent {}

class ConnectivityChanged extends ConnectivityEvent {
  final List<ConnectivityResult> results;
  ConnectivityChanged(this.results);
}
