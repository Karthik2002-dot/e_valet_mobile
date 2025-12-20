import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/profile_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home_view.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DriverMenuBloc()),
        BlocProvider(create: (_) => DriverStatusBloc()..add(const DriverStatusStarted())),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DriverMenuBloc, DriverMenuState>(
            listener: (context, state) {
              if (state is DriverMenuLogoutSuccess) {
                // Show success message
                SnackBars.showSuccessSnackBar(context, state.response.message);
                // Navigate to login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
                // Reset state
                context.read<DriverMenuBloc>().add(const DriverMenuReset());
              } else if (state is DriverMenuLogoutFailure) {
                // Show error message
                SnackBars.showErrorSnackBar(context, state.message);
                // Still navigate to login screen even on failure (tokens are cleared locally)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
                // Reset state
                context.read<DriverMenuBloc>().add(const DriverMenuReset());
              } else if (state is DriverMenuAction) {
                switch (state.action) {
                  case DriverMenuActionType.profile:
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                    // Reset state so the same action can be handled again later
                    context.read<DriverMenuBloc>().add(const DriverMenuReset());
                    break;
                  case DriverMenuActionType.logout:
                    // This case is now handled by DriverMenuLogoutSuccess/Failure
                    break;
                }
              }
            },
          ),
          BlocListener<DriverStatusBloc, DriverStatusState>(
            listener: (context, state) {
              if (state is DriverStatusClockInSuccess) {
                // Show success snackbar with message from API
                SnackBars.showSuccessSnackBar(context, state.message);
              } else if (state is DriverStatusClockOutSuccess) {
                // Show success snackbar with message from API
                SnackBars.showSuccessSnackBar(context, state.message);
              } else if (state is DriverBreakStartSuccess) {
                // Show success snackbar with message from API
                SnackBars.showSuccessSnackBar(context, state.message);
              } else if (state is DriverBreakEndSuccess) {
                // Show success snackbar with message from API
                SnackBars.showSuccessSnackBar(context, state.message);
              } else if (state is DriverStatusError) {
                // Show error snackbar
                SnackBars.showErrorSnackBar(context, state.message);
              }
            },
          ),
        ],
        child: const DriverHomeView(),
      ),
    );
  }
}
