import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:niloufer_valet_mobile/bloc/driver/assigned_sessions_background/assigned_sessions_background_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_state.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_camera_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home_view.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/session_incomplete_dialog.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/assigned_session_sheet_loader.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/profile_screen.dart';

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

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({
    super.key,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with WidgetsBindingObserver, RouteAware {
  Timer? _dismissTimer;
  final ValueNotifier<bool> _dismissNotifier = ValueNotifier(false);
  final DriverHomeRouteObserver _routeObserver = DriverHomeRouteObserver();
  Timer? _webSocketCheckTimer;

  // Store bloc references to avoid context issues in timer callbacks
  AssignedSessionsBackgroundBloc? _assignedBloc;

  // Track if we've already shown the session incomplete dialog
  bool _hasShownSessionDialog = false;

  // Track if permissions have been requested
  bool _hasRequestedPermissions = false;

  void _presentAssignedSessionSheet(BuildContext context) {
    _dismissNotifier.value = false;
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 60), () {
      if (mounted) {
        _dismissNotifier.value = true;
      }
    });

    final assignedSessionsBloc = context.read<AssignedSessionsBackgroundBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      isDismissible: _dismissNotifier.value,
      enableDrag: false,
      builder: (BuildContext modalContext) => BlocProvider.value(
        value: assignedSessionsBloc,
        child: ValueListenableBuilder<bool>(
          valueListenable: _dismissNotifier,
          builder: (context, canDismiss, _) {
            return Stack(
              children: [
                if (canDismiss)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(modalContext).pop();
                        _cleanupTimer();
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.001),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.6,
                    child: Stack(
                      children: [
                        const AssignedSessionSheetLoader(),
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
      ),
    ).then((_) {
      _cleanupTimer();
    });
  }

  void _cleanupTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _dismissNotifier.value = false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _routeObserver.setOnRouteChanged(_onRouteChanged);

    // Request permissions when driver home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });

    // Start periodic WebSocket health check
    _startWebSocketHealthCheck();
  }

  Future<void> _requestPermissions() async {
    // Only request once per screen load
    if (_hasRequestedPermissions) return;
    _hasRequestedPermissions = true;

    // Request Location Permission
    LocationPermission locationPermission =
        await LocationService.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await LocationService.requestPermission();
    }

    if (locationPermission != LocationPermission.denied &&
        locationPermission != LocationPermission.deniedForever) {
      // Get current location and store it
      try {
        final position = await LocationService.getCurrentLocation();
        final latitude = position.latitude;
        final longitude = position.longitude;
        final location =
            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

        await TokenStorage.saveCurrentLocation(
          latitude: latitude,
          longitude: longitude,
          location: location,
        );
      } catch (e) {
        // Continue even if location fetch fails
      }
    }

    // Request Camera Permission
    await Permission.camera.request();
  }

  void _onRouteChanged() {
    // The Builder widget in build() will handle the refresh
  }

  void _startWebSocketHealthCheck() {
    _webSocketCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _checkWebSocketHealth();
      }
    });
  }

  void _checkWebSocketHealth() {
    try {
      // Use stored bloc reference instead of context.read() to avoid Provider errors
      if (_assignedBloc == null) {
        return;
      }

      final webSocketBloc = context.read<WebSocketBloc>();

      // If WebSocket is connected but we don't have sessions, refresh
      if (webSocketBloc.isConnected &&
          _assignedBloc!.state is AssignedSessionsBackgroundInitial) {
        _assignedBloc!.add(const RefreshAssignedSessions());
      }
    } catch (e) {
      print('WebSocket health check error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App came back to foreground - check WebSocket
      _checkWebSocketOnResume();
    }
  }

  @override
  void didUpdateWidget(covariant DriverHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Builder widget in build() will handle refresh on widget update
  }

  void _checkWebSocketOnResume() {
    // The Builder widget in build() will handle the refresh when app resumes
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _routeObserver.subscribe(this, route);
    }

    // Builder widget in build() will handle WebSocket checks
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // Builder widget in build() will handle refresh
  }

  @override
  void didPush() {
    super.didPush();
    // Builder widget in build() will handle refresh
  }

  @override
  void dispose() {
    _webSocketCheckTimer?.cancel();
    _routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _assignedBloc = null; // Clear bloc reference
    _cleanupTimer();
    _dismissNotifier.dispose();
    _hasShownSessionDialog = false; // Reset flag
    _hasRequestedPermissions = false; // Reset permission flag
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DriverMenuBloc()),
        BlocProvider(
            create: (context) => AssignedSessionsBackgroundBloc(
                  webSocketBloc: context.read<WebSocketBloc>(),
                )),
        BlocProvider(
            create: (_) =>
                DriverStatusBloc()..add(const DriverStatusStarted())),
      ],
      child: Builder(
        builder: (context) {
          // Now we can safely access the blocs since we're inside the MultiBlocProvider
          try {
            final assignedBloc = context.read<AssignedSessionsBackgroundBloc>();
            // Store the bloc reference for use in timer callbacks
            _assignedBloc = assignedBloc;

            // Force immediate refresh on every build
            assignedBloc.add(const RefreshAssignedSessions());

            // WebSocket listeners are automatically set up in bloc constructor
          } catch (e) {
            _assignedBloc = null;
          }

          return MultiBlocListener(
            listeners: [
              BlocListener<AssignedSessionsBackgroundBloc,
                  AssignedSessionsBackgroundState>(
                listener: (blocContext, state) {
                  if (state is AssignedSessionsBackgroundData) {
                    if (state.hasSessions) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted &&
                            ModalRoute.of(blocContext)?.isCurrent == true) {
                          _presentAssignedSessionSheet(blocContext);
                        }
                      });
                    }
                  } else if (state is AssignedSessionsCancelled) {
                    // Close the bottom sheet if open
                    if (Navigator.of(blocContext).canPop()) {
                      Navigator.of(blocContext).pop();
                    }
                    _cleanupTimer(); // Ensure timer is cleaned up
                  }
                },
              ),
              // Add WebSocket connection monitoring
              BlocListener<WebSocketBloc, WebSocketState>(
                listener: (context, state) {
                  // WebSocket state monitoring (no debug prints needed)
                },
              ),
              BlocListener<DriverMenuBloc, DriverMenuState>(
                listener: (context, state) {
                  if (state is DriverMenuLogoutSuccess) {
                    // Show success message
                    SnackBars.showSuccessSnackBar(
                        context, state.response.message);
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
                        context
                            .read<DriverMenuBloc>()
                            .add(const DriverMenuReset());
                        break;
                      case DriverMenuActionType.logout:
                        // This case is now handled by DriverMenuLogoutSuccess/Failure
                        break;
                    }
                  } else if (state is DriverHomeLoaded) {
                    // Check if there's a CHECKED_IN session and show dialog
                    // Only show once per screen load
                    if (!_hasShownSessionDialog &&
                        state.pendingSessions != null &&
                        state.pendingSessions!.hasCheckedInSession) {
                      _hasShownSessionDialog = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted &&
                            ModalRoute.of(context)?.isCurrent == true) {
                          final checkedInSession =
                              state.pendingSessions!.checkedInSession;
                          if (checkedInSession != null) {
                            SessionIncompleteDialog.show(
                              context,
                              onContinue: () {
                                // Navigate to camera screen with back navigation prevented
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CarCameraScreen(
                                      sessionId: checkedInSession.sessionId,
                                      preventBackNavigation: true,
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      });
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
            child: GestureDetector(
              onTap: () {
                try {
                  final assignedBloc =
                      context.read<AssignedSessionsBackgroundBloc>();
                  assignedBloc.add(const RefreshAssignedSessions());
                } catch (e) {
                  print('Manual WebSocket refresh failed: $e');
                }
              },
              child: const DriverHomeView(),
            ),
          );
        },
      ),
    );
  }
}
