import 'package:flutter/material.dart';

/// Must be included in [MaterialApp.navigatorObservers] so [RouteAware] on
/// [DriverHomeScreen] receives [RouteAware.didPopNext] when routes above home pop.
class DriverHomeRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  static final DriverHomeRouteObserver _instance =
      DriverHomeRouteObserver._internal();
  factory DriverHomeRouteObserver() => _instance;
  DriverHomeRouteObserver._internal();

  void Function()? _onRouteChanged;

  void setOnRouteChanged(void Function() callback) {
    _onRouteChanged = callback;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _onRouteChanged?.call();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _onRouteChanged?.call();
  }
}
