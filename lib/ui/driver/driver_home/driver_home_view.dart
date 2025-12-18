import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_state.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home_content.dart';

class DriverHomeView extends StatelessWidget {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverMenuBloc, DriverMenuState>(
      builder: (context, state) {
        if (state is! DriverHomeLoaded) {
          // Trigger loading if not already loaded
          if (state is DriverMenuInitial) {
            context.read<DriverMenuBloc>().add(const DriverHomeStarted());
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final driverName = state.driverName;
        final isOnBreak = state.isOnBreak;
        final isOnline = state.isOnline;

        return DriverHomeContent(
          driverName: driverName,
          isOnBreak: isOnBreak,
          isOnline: isOnline,
        );
      },
    );
  }
}
