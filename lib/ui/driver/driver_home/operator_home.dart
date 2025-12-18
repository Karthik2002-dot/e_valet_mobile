import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/operator_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/operator_menu_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/core/login/login.dart';
import 'package:niloufer_valet_mobile/ui/core/profile/operator_profile_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/operator_home_view.dart';

class OperatorHomeScreen extends StatelessWidget {
  const OperatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperatorMenuBloc(),
      child: BlocListener<OperatorMenuBloc, OperatorMenuState>(
        listener: (context, state) {
          if (state is OperatorMenuLogoutSuccess) {
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
            context.read<OperatorMenuBloc>().add(const OperatorMenuReset());
          } else if (state is OperatorMenuLogoutFailure) {
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
            context.read<OperatorMenuBloc>().add(const OperatorMenuReset());
          } else if (state is OperatorMenuAction) {
            switch (state.action) {
              case OperatorMenuActionType.profile:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OperatorProfileScreen(),
                  ),
                );
                // Reset state so the same action can be handled again later
                context.read<OperatorMenuBloc>().add(const OperatorMenuReset());
                break;
              case OperatorMenuActionType.logout:
                // This case is now handled by OperatorMenuLogoutSuccess/Failure
                break;
            }
          }
        },
        child: const OperatorHomeView(),
      ),
    );
  }
}
