import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/bloc/driver/assigned_sessions_background/assigned_sessions_background_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_state.dart';
import 'package:niloufer_valet_mobile/services/notification/firebase_messaging_service.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/guidelines/guidelines_screen.dart';
import 'package:niloufer_valet_mobile/ui/help_support/help_screen.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/car_photo_intro_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home_view.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/session_incomplete_dialog.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/assigned_session_sheet_loader.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/profile_screen.dart';
import 'package:niloufer_valet_mobile/utils/session_converter.dart';

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
  /// When this changes, DriverHomeContent resets so home (two cards) is shown on reopen/return.
  final ValueNotifier<int> _homeResetNotifier = ValueNotifier(0);
  final DriverHomeRouteObserver _routeObserver = DriverHomeRouteObserver();
  Timer? _webSocketCheckTimer;
  StreamSubscription<void>? _retrievalNotificationTapSubscription;
  bool _refreshPendingFromNotification = false;
  bool _subscribedToRetrievalTap = false;

  /// When opening from retrieval push, assigned sessions may emit before
  /// [DriverMenuBloc] has loaded; we skip showing the sheet. Set this so we
  /// re-check when [DriverHomeLoaded] arrives.
  bool _pendingShowSheetWhenMenuLoaded = false;

  /// When we skip showing the sheet because route isn't current yet (e.g. app
  /// just resumed from notification), we schedule one retry. This avoids
  /// scheduling multiple retries.
  bool _didScheduleSheetRetryForRoute = false;
  bool _pendingShowSheetWhenRouteCurrent = false;
  bool _isShowingAssignedSheet = false;

  // Store bloc references to avoid context issues in timer callbacks
  AssignedSessionsBackgroundBloc? _assignedBloc;
  WebSocketBloc? _webSocketBloc;

  // Track if we've already shown the session incomplete dialog
  bool _hasShownSessionDialog = false;

  // Track if we've already navigated for accepted/arrived sessions
  bool _hasNavigatedForStatus = false;

  // Track if 5-second assigned-sessions polling has been started (start once, stop on dispose)
  bool _assignedSessionsPollingStarted = false;

  // Poll pending sessions every 5s so operator override (e.g. ARRIVED in Car Logs) is detected
  Timer? _pendingSessionsPollTimer;
  bool _pendingSessionsPollingStarted = false;
  static const int _pendingSessionsPollIntervalSeconds = 5;

  void _refreshPendingSessions() {
    try {
      context.read<DriverMenuBloc>().add(const DriverPendingSessionsRefresh());
    } catch (e) {
      // Ignore refresh errors when context is not ready
    }
  }

  void _presentAssignedSessionSheet(BuildContext context) {
    _isShowingAssignedSheet = true;
    final assignedSessionsBloc = context.read<AssignedSessionsBackgroundBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      // Critical: this sheet must NOT close via outside tap, swipe/drag, or back.
      // It should close only when our backend/API state indicates no sessions.
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext modalContext) => BlocProvider.value(
        value: assignedSessionsBloc,
        child: PopScope(
          canPop: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.6,
              alignment: Alignment.bottomCenter,
              child: const AssignedSessionSheetLoader(),
            ),
          ),
        ),
      ),
    ).then((_) {
      _isShowingAssignedSheet = false;
    });
  }

  void _closeAssignedSessionSheetIfOpen(BuildContext context) {
    if (!_isShowingAssignedSheet) return;
    // Try root navigator first since modal sheets may be attached there.
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    if (rootNavigator.canPop()) {
      rootNavigator.pop();
      return;
    }
    // Fallback to local navigator.
    final localNavigator = Navigator.of(context);
    if (localNavigator.canPop()) {
      localNavigator.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _routeObserver.setOnRouteChanged(_onRouteChanged);

    // Location and camera are requested on PermissionsScreen before reaching this screen.

    // Start periodic WebSocket health check
    _startWebSocketHealthCheck();
  }

  void _onRouteChanged() {
    if (!mounted) return;
    if (_pendingShowSheetWhenRouteCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _attemptShowAssignedSessionSheet(context);
      });
    }
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
      if (_assignedBloc == null || _webSocketBloc == null) return;
      if (_assignedBloc!.isClosed || _webSocketBloc!.isClosed) return;

      if (_webSocketBloc!.isConnected &&
          _assignedBloc!.state is AssignedSessionsBackgroundInitial) {
        if (!_assignedBloc!.isClosed) {
          _assignedBloc!.add(const RefreshAssignedSessions());
        }
      }
    } catch (e) {
      debugPrint('WebSocket health check error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App came back to foreground - preserve current screen (do not reset to home).
      // User stays on QR/park flow unless they press back.
      _checkWebSocketOnResume();
      _hasNavigatedForStatus = false;
      _refreshPendingSessions();
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
    _webSocketBloc ??= context.read<WebSocketBloc>();

    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _routeObserver.subscribe(this, route);
    }

    // When app is opened from retrieval push notification, refresh pending/session API
    if (!_subscribedToRetrievalTap) {
      try {
        final fcm =
            Provider.of<FirebaseMessagingService>(context, listen: false);
        _retrievalNotificationTapSubscription =
            fcm.onRetrievalNotificationTap.listen((_) {
          if (mounted) {
            setState(() => _refreshPendingFromNotification = true);
          }
        });
        _subscribedToRetrievalTap = true;
      } catch (e, stackTrace) {
        debugPrint('Failed to subscribe to retrieval notification taps: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // When user returns to driver home (e.g. from Car Camera or Confirm Arrival), reset so home (two cards) is shown, not Vehicle details.
    _homeResetNotifier.value++;
    // Reset so we can navigate to Confirm Arrival again if operator changed status while we were away
    _hasNavigatedForStatus = false;
    _refreshPendingSessions();
  }

  @override
  void didPush() {
    super.didPush();
    // Builder widget in build() will handle refresh
  }

  @override
  void dispose() {
    _webSocketCheckTimer?.cancel();
    try {
      if (_assignedBloc != null && !_assignedBloc!.isClosed) {
        _assignedBloc!.add(const StopAssignedSessionsPolling());
      }
    } catch (_) {
      // Bloc may already be closed during teardown
    }
    _retrievalNotificationTapSubscription?.cancel();
    _routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _assignedBloc = null;
    _webSocketBloc = null;
    _assignedSessionsPollingStarted = false;
    _pendingSessionsPollTimer?.cancel();
    _pendingSessionsPollTimer = null;
    _pendingSessionsPollingStarted = false;
    _hasShownSessionDialog = false; // Reset flag
    _hasNavigatedForStatus = false; // Reset navigation flag
    _pendingShowSheetWhenMenuLoaded = false;
    _didScheduleSheetRetryForRoute = false;
    _pendingShowSheetWhenRouteCurrent = false;
    _isShowingAssignedSheet = false;
    super.dispose();
  }

  void _attemptShowAssignedSessionSheet(BuildContext blocContext) {
    if (!mounted || _isShowingAssignedSheet) return;

    if (ModalRoute.of(blocContext)?.isCurrent != true) {
      _pendingShowSheetWhenRouteCurrent = true;
      return;
    }

    final assignedState =
        blocContext.read<AssignedSessionsBackgroundBloc>().state;
    if (assignedState is! AssignedSessionsBackgroundData ||
        !assignedState.hasSessions) {
      return;
    }

    final driverMenuState = blocContext.read<DriverMenuBloc>().state;
    if (driverMenuState is! DriverHomeLoaded) {
      _pendingShowSheetWhenMenuLoaded = true;
      return;
    }

    // Block sheet when we handle any of these via direct navigation (Confirm Arrival or vehicle details).
    final pendingSessions = driverMenuState.pendingSessions;
    final hasBlockingStatus = pendingSessions != null &&
        (pendingSessions.hasArrivedSession ||
            pendingSessions.hasAcceptedSession ||
            pendingSessions.hasReparkingSession ||
            pendingSessions.hasCheckedInSession);
    if (hasBlockingStatus) {
      return;
    }

    _pendingShowSheetWhenMenuLoaded = false;
    _pendingShowSheetWhenRouteCurrent = false;
    _didScheduleSheetRetryForRoute = false;
    _presentAssignedSessionSheet(blocContext);
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

            // Start 5-second polling for assigned-to-me API while user is on this screen
            if (!_assignedSessionsPollingStarted) {
              _assignedSessionsPollingStarted = true;
              assignedBloc.add(const StartAssignedSessionsPolling());
            }

            // Start 5-second polling for pending sessions (GET /sessions/pending) so operator
            // override in Car Logs (e.g. status changed to ARRIVED) is detected and we navigate
            // to Confirm Arrival with the correct UI
            if (!_pendingSessionsPollingStarted) {
              _pendingSessionsPollingStarted = true;
              _pendingSessionsPollTimer = Timer.periodic(
                const Duration(seconds: _pendingSessionsPollIntervalSeconds),
                (_) {
                  if (mounted) _refreshPendingSessions();
                },
              );
            }

            // When opened from retrieval notification tap, refresh session/pending API first
            if (_refreshPendingFromNotification) {
              _refreshPendingFromNotification = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _refreshPendingSessions();
                assignedBloc.add(const RefreshAssignedSessions());
              });
            } else {
              // Force immediate refresh on every build when not triggered by notification
              assignedBloc.add(const RefreshAssignedSessions());
            }
            // WebSocket listeners are automatically set up in bloc constructor
          } catch (e) {
            _assignedBloc = null;
          }

          return MultiBlocListener(
            listeners: [
              BlocListener<AssignedSessionsBackgroundBloc,
                  AssignedSessionsBackgroundState>(
                listener: (blocContext, state) {
                  // Only "data available" means AssignedSessionsBackgroundData with sessions
                  final hasData = state is AssignedSessionsBackgroundData &&
                      state.hasSessions;
                  // No data (empty, initial, or cancelled) → close sheet; never show empty sheet
                  if (!hasData) {
                    _closeAssignedSessionSheetIfOpen(blocContext);
                    return;
                  }
                  // Data available → show sheet only when we have sessions (with data)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    if (ModalRoute.of(blocContext)?.isCurrent == true) {
                      _attemptShowAssignedSessionSheet(blocContext);
                    } else if (!_didScheduleSheetRetryForRoute) {
                      _pendingShowSheetWhenRouteCurrent = true;
                      _didScheduleSheetRetryForRoute = true;
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (!mounted) return;
                        try {
                          blocContext
                              .read<AssignedSessionsBackgroundBloc>()
                              .add(const RefreshAssignedSessions());
                        } catch (_) {}
                      });
                    }
                  });
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
                      case DriverMenuActionType.guidelines:
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GuidelinesScreen(),
                          ),
                        );
                        context
                            .read<DriverMenuBloc>()
                            .add(const DriverMenuReset());
                        break;
                      case DriverMenuActionType.help:
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HelpScreen(),
                          ),
                        );
                        context
                            .read<DriverMenuBloc>()
                            .add(const DriverMenuReset());
                        break;
                      case DriverMenuActionType.logout:
                        // This case is now handled by DriverMenuLogoutSuccess/Failure
                        break;
                    }
                  } else if (state is DriverHomeLoaded) {
                    // If we skipped showing the retrieval sheet earlier (opened from
                    // push) because menu wasn't loaded, re-trigger so the sheet shows now.
                    if (_pendingShowSheetWhenMenuLoaded && mounted) {
                      _pendingShowSheetWhenMenuLoaded = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _attemptShowAssignedSessionSheet(context);
                      });
                    }

                    // Check if there's a CHECKED_IN session and show dialog
                    // Only show once per screen load

                    // Priority order: ARRIVED > ACCEPTED > REPARKING > CHECKED_IN
                    // ARRIVED/ACCEPTED: go directly to Confirm Arrival so app reopen after accept triggers correctly (session/pending API).
                    if (!_hasNavigatedForStatus &&
                        state.pendingSessions != null &&
                        state.pendingSessions!.hasArrivedSession) {
                      _hasNavigatedForStatus = true;
                      _closeAssignedSessionSheetIfOpen(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted &&
                            ModalRoute.of(context)?.isCurrent == true) {
                          final arrivedSession =
                              state.pendingSessions!.arrivedSession;
                          if (arrivedSession != null) {
                            final assignedSession =
                                SessionConverter.pendingToAssigned(
                                    arrivedSession);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ConfirmArrivalScreen(
                                  session: assignedSession,
                                  preventBackNavigation: true,
                                  showHandoverOnLoad: true,
                                ),
                              ),
                            );
                          }
                        }
                      });
                    } else if (!_hasNavigatedForStatus &&
                        state.pendingSessions != null &&
                        state.pendingSessions!.hasAcceptedSession) {
                      _hasNavigatedForStatus = true;
                      _closeAssignedSessionSheetIfOpen(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted &&
                            ModalRoute.of(context)?.isCurrent == true) {
                          final acceptedSession =
                              state.pendingSessions!.acceptedSession;
                          if (acceptedSession != null) {
                            final assignedSession =
                                SessionConverter.pendingToAssigned(
                                    acceptedSession);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ConfirmArrivalScreen(
                                  session: assignedSession,
                                  preventBackNavigation: true,
                                ),
                              ),
                            );
                          }
                        }
                      });
                    }
                    // Check for REPARKING status — open latest vehicle details screen (Scan / Type Parking Number)
                    else if (!_hasNavigatedForStatus &&
                        state.pendingSessions != null &&
                        state.pendingSessions!.hasReparkingSession) {
                      _hasNavigatedForStatus = true;
                      _closeAssignedSessionSheetIfOpen(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted &&
                            ModalRoute.of(context)?.isCurrent == true) {
                          final reparkingSession =
                              state.pendingSessions!.reparkingSession;
                          if (reparkingSession != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CarPhotoIntroScreen(
                                  cameViaTagNumber: false,
                                  sessionId: reparkingSession.sessionId,
                                  isReparking: true,
                                ),
                              ),
                            );
                          }
                        }
                      });
                    }
                    // Check for CHECKED_IN session and show dialog — on Continue open latest vehicle details screen (Scan / Type Parking Number)
                    else if (!_hasShownSessionDialog &&
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
                              cardNumber:
                                  checkedInSession.cardNumber.toString(),
                              onContinue: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CarPhotoIntroScreen(
                                      cameViaTagNumber: false,
                                      sessionId: checkedInSession.sessionId,
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
                  if (state is DriverBreakStartSuccess) {
                    SnackBars.showSuccessSnackBar(context, state.message);
                  } else if (state is DriverBreakEndSuccess) {
                    SnackBars.showSuccessSnackBar(context, state.message);
                  } else if (state is DriverStatusError) {
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
              child: DriverHomeView(homeResetNotifier: _homeResetNotifier),
            ),
          );
        },
      ),
    );
  }
}
