import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/assigned_sessions_background/assigned_sessions_background_bloc.dart';
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
  const DriverHomeScreen({
    super.key,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  Timer? _dismissTimer;
  final ValueNotifier<bool> _dismissNotifier = ValueNotifier(false);

  void _presentAssignedSessionSheet() {
    // Reset dismiss state
    _dismissNotifier.value = false;

    // Cancel any existing timer
    _dismissTimer?.cancel();

    // Set timer to allow dismissal after 60 seconds
    _dismissTimer = Timer(const Duration(seconds: 60), () {
      if (mounted) {
        _dismissNotifier.value = true;
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      isDismissible: _dismissNotifier.value, // Controlled by ValueNotifier
      enableDrag: false, // Disable drag to dismiss
      builder: (BuildContext modalContext) => ValueListenableBuilder<bool>(
        valueListenable: _dismissNotifier,
        builder: (context, canDismiss, _) {
          return Stack(
            children: [
              // Invisible barrier that captures taps when dismissible
              if (canDismiss)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(modalContext).pop();
                      _cleanupTimer();
                    },
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.001), // Nearly invisible but tappable
                    ),
                  ),
                ),
              // The actual bottom sheet content
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.6,
                  child: Stack(
                    children: [
                      const AssignedSessionSheetLoader(),
                      // Invisible overlay that captures taps when dismissible
                      if (canDismiss)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(modalContext).pop();
                              _cleanupTimer();
                            },
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      // Cleanup when sheet is closed
      _cleanupTimer();
    });
  }

  void _cleanupTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _dismissNotifier.value = false;
  }

  @override
  void dispose() {
    _cleanupTimer();
    _dismissNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DriverMenuBloc()),
        BlocProvider(create: (_) => AssignedSessionsBackgroundBloc()),
        BlocProvider(
            create: (_) =>
                DriverStatusBloc()..add(const DriverStatusStarted())),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AssignedSessionsBackgroundBloc,
              AssignedSessionsBackgroundState>(
            listener: (context, state) {
              if (state is AssignedSessionsBackgroundData &&
                  state.hasSessions) {
                // Show bottom sheet when new assigned sessions data arrives
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && ModalRoute.of(context)?.isCurrent == true) {
                    _presentAssignedSessionSheet();
                  }
                });
              }
            },
          ),
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
