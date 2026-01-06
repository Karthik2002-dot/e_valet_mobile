import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_slots/operator_slots_screen.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/operator_drivers_screen.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_car_logs/operator_car_logs_screen.dart';

class OperatorScreenRouter {
  static Widget getScreen(int selectedIndex, Widget dashboardContent, int refreshKey) {
    switch (selectedIndex) {
      case 0:
        return dashboardContent;
      case 1:
        return OperatorSlotsScreen(key: ValueKey(refreshKey));
      case 2:
        return OperatorDriversScreen(key: ValueKey(refreshKey));
      case 3:
        return OperatorCarLogsScreen(key: ValueKey(refreshKey));
      default:
        return dashboardContent;
    }
  }
}
