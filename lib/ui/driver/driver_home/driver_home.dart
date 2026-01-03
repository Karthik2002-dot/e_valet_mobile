import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home_view.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/assigned_session_sheet_loader.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/profile_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  final bool showAssignedSessionSheet;

  const DriverHomeScreen({
    super.key,
    this.showAssignedSessionSheet = false,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _sheetPresented = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryShowAssignedSessionSheet();
  }

  @override
  void didUpdateWidget(covariant DriverHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAssignedSessionSheet != oldWidget.showAssignedSessionSheet) {
      _tryShowAssignedSessionSheet();
    }
  }

  void _tryShowAssignedSessionSheet() {
    if (!widget.showAssignedSessionSheet || _sheetPresented) return;
    _sheetPresented = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _presentAssignedSessionSheet();
    });
  }

  void _presentAssignedSessionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.6,
        alignment: Alignment.bottomCenter,
        child: AssignedSessionSheetLoader(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DriverMenuBloc()),
        BlocProvider(
            create: (_) =>
                DriverStatusBloc()..add(const DriverStatusStarted())),
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
