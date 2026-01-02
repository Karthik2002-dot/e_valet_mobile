import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_slots/operator_slots_screen.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/operator_drivers_screen.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_car_logs/operator_car_logs_screen.dart';

class OperatorScreenRouter {
  static Widget getScreen(int selectedIndex, Widget dashboardContent) {
    switch (selectedIndex) {
      case 0:
        return dashboardContent;
      case 1:
        return const OperatorSlotsScreen();
      case 2:
        return const OperatorDriversScreen();
      case 3:
        return const OperatorCarLogsScreen();
      default:
        return dashboardContent;
    }
  }
}
