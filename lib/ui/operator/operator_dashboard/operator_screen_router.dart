import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/operator_drivers_screen.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_car_logs/operator_car_logs_screen.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_parked_car/operator_parked_car_screen.dart';

class OperatorScreenRouter {
  static Widget getScreen(
    int selectedIndex,
    Widget dashboardContent,
    int refreshKey, {
    Function(VoidCallback)? onSlotsRefreshReady,
    Function(VoidCallback)? onDriversRefreshReady,
    Function(int)? onNavigateToTab,
  }) {
    switch (selectedIndex) {
      case 0:
        return dashboardContent;
      case 1:
        return OperatorParkedCarScreen(
          key: ValueKey(refreshKey),
          onRefreshReady: onSlotsRefreshReady,
          onNavigateToTab: onNavigateToTab,
        );
      case 2:
        return OperatorDriversScreen(
          key: ValueKey(refreshKey),
          onRefreshReady: onDriversRefreshReady,
          onNavigateToTab: onNavigateToTab,
        );
      case 3:
        return OperatorCarLogsScreen(
          key: ValueKey(refreshKey),
          onNavigateToTab: onNavigateToTab,
        );
      default:
        return dashboardContent;
    }
  }
}
