import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/assigned_sessions_background/assigned_sessions_background_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/pass_available_drivers/pass_available_drivers_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/pass_available_drivers/pass_available_drivers_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/pass_available_drivers/pass_available_drivers_state.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_request_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_request_event.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_requesy_state.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/models/driver/session/pass_available_driver.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/retrieval_request_sheet.dart';
import 'package:niloufer_valet_mobile/services/vibration_controller.dart';

class AssignedSessionSheetLoader extends StatefulWidget {
  const AssignedSessionSheetLoader({super.key});

  @override
  State<AssignedSessionSheetLoader> createState() =>
      _AssignedSessionSheetLoaderState();
}

class _AssignedSessionSheetLoaderState
    extends State<AssignedSessionSheetLoader> {
  bool _isAcceptLoading = false;
  DateTime? _acceptTriggeredAt;

  /// The session ID for which we last fetched available pass-drivers.
  String? _lastFetchedSessionId;

  @override
  void dispose() {
    VibrationController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssignedSessionsBackgroundBloc,
        AssignedSessionsBackgroundState>(
      buildWhen: (previous, current) {
        if (current is! AssignedSessionsBackgroundData) return true;
        if (!current.hasSessions) return true;
        if (previous is! AssignedSessionsBackgroundData ||
            !previous.hasSessions) {
          return true;
        }
        return AssignedSessionsBackgroundBloc.displayKeyOfFirstSession(
                previous.sessions) !=
            AssignedSessionsBackgroundBloc.displayKeyOfFirstSession(
                current.sessions);
      },
      builder: (context, assignedState) {
        if (assignedState is AssignedSessionsBackgroundData) {
          if (!assignedState.hasSessions) {
            VibrationController.stop();
            return const SizedBox.shrink();
          }
          final rawSession = assignedState.sessions.first;

          AssignedSession? typedSession;
          String? sessionId;
          dynamic sessionJson;

          if (rawSession != null) {
            if (rawSession is AssignedSession) {
              typedSession = rawSession;
              sessionId = rawSession.id;
              sessionJson = rawSession.toJson();
            } else if (rawSession is Map<String, dynamic>) {
              final rawId =
                  (rawSession['sessionId'] ?? rawSession['id'])?.toString();
              sessionId = (rawId != null && rawId.isNotEmpty) ? rawId : null;
              sessionJson = rawSession;
              try {
                typedSession = AssignedSession.fromJson(rawSession);
                if (sessionId == null && typedSession.id.isNotEmpty) {
                  sessionId = typedSession.id;
                }
              } catch (_) {}
            }

            if (sessionId != null) {
              TokenStorage.saveSessionIdFromGetApi(sessionId).catchError((_) {});
            }
            if (sessionJson != null) {
              TokenStorage.saveAssignedSessionData(sessionJson).catchError((_) {});
              String? parkingLocation;
              if (typedSession != null &&
                  typedSession.parkingLocation.isNotEmpty) {
                parkingLocation = typedSession.parkingLocation;
              } else if (sessionJson is Map<String, dynamic>) {
                final rawLocation = sessionJson['parkingLocation'];
                if (rawLocation != null) {
                  parkingLocation = rawLocation.toString();
                }
              }
              if (parkingLocation != null && parkingLocation.trim().isNotEmpty) {
                TokenStorage.saveParkingLocation(parkingLocation)
                    .catchError((_) {});
              }
            }
          }

          final effectiveSessionId = sessionId ?? typedSession?.id;
          final canAccept =
              effectiveSessionId != null && effectiveSessionId.isNotEmpty;

          // Fallback: start vibration if the widget becomes visible with a
          // session but the notification handler didn't trigger it yet
          // (e.g. user opened the app manually after a background notification).
          if (typedSession != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) VibrationController.startRetrievalAlert();
            });
          }

          return Align(
            alignment: Alignment.bottomCenter,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => RetrivalRequestBloc()),
                BlocProvider(create: (_) => PassAvailableDriversBloc()),
              ],
              child: Builder(
                builder: (blocContext) {
                  // Fetch available pass-drivers once per unique session
                  if (effectiveSessionId != null &&
                      effectiveSessionId != _lastFetchedSessionId) {
                    _lastFetchedSessionId = effectiveSessionId;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (blocContext.mounted) {
                        blocContext.read<PassAvailableDriversBloc>().add(
                              FetchPassAvailableDrivers(effectiveSessionId),
                            );
                      }
                    });
                  }

                  return MultiBlocListener(
                    listeners: [
                      // RetrivalRequest listener (accept flow)
                      BlocListener<RetrivalRequestBloc, RetrivalRequestState>(
                        listener: (context, state) {
                          if (state is RetrivalRequestLoading) {
                            if (mounted) {
                              setState(() => _isAcceptLoading = true);
                            }
                          } else if (state is RetrivalRequestAccepted) {
                            SnackBars.showSuccessSnackBar(
                                context, state.message);
                            if (mounted) {
                              setState(() => _isAcceptLoading = false);
                            }
                            Navigator.of(context).pop();
                            _navigateToConfirmArrival(context);
                          } else if (state is RetrivalRequestError) {
                            SnackBars.showErrorSnackBar(context, state.message);
                            if (mounted) {
                              setState(() => _isAcceptLoading = false);
                            }
                          }
                        },
                      ),

                      // PassAvailableDrivers listener (pass flow)
                      BlocListener<PassAvailableDriversBloc,
                          PassAvailableDriversState>(
                        listener: (context, state) {
                          if (state is SessionPassedToDriver) {
                            SnackBars.showSuccessSnackBar(
                                context, state.message);
                            // Close the bottom sheet — session has been passed
                            Navigator.of(context).pop();
                          } else if (state is PassToDriverError) {
                            SnackBars.showErrorSnackBar(
                                context, state.message);
                          }
                        },
                      ),
                    ],
                    child: BlocBuilder<PassAvailableDriversBloc,
                        PassAvailableDriversState>(
                      builder: (context, passState) {
                        final drivers = _driversFromState(passState);
                        final isDriversLoading =
                            passState is PassAvailableDriversLoading;
                        final passingDriverId =
                            passState is PassingSessionToDriver
                                ? passState.driverId
                                : null;

                        return RetrievalRequestSheet(
                          session: typedSession,
                          message: typedSession == null
                              ? 'No active retrieval requests'
                              : null,
                          isLoading: false,
                          isAcceptLoading: _isAcceptLoading,
                          onAccept: canAccept
                              ? () {
                                  if (_isAcceptLoading) return;
                                  VibrationController.stop();
                                  setState(() {
                                    _isAcceptLoading = true;
                                    _acceptTriggeredAt = DateTime.now();
                                  });
                                  if (blocContext.mounted) {
                                    blocContext
                                        .read<RetrivalRequestBloc>()
                                        .add(AcceptRetrivalRequest(
                                            effectiveSessionId));
                                  } else if (mounted) {
                                    setState(() => _isAcceptLoading = false);
                                  }
                                }
                              : (typedSession != null
                                  ? () {
                                      SnackBars.showErrorSnackBar(
                                        context,
                                        'Unable to accept: session info is missing.',
                                      );
                                    }
                                  : null),
                          // Pass-to-driver params
                          availableDrivers: drivers,
                          isDriversLoading: isDriversLoading,
                          passingDriverId: passingDriverId,
                          onPassToDriver: (effectiveSessionId != null &&
                                  passingDriverId == null &&
                                  !_isAcceptLoading)
                              ? (PassAvailableDriver driver) {
                                  VibrationController.stop();
                                  context
                                      .read<PassAvailableDriversBloc>()
                                      .add(PassSessionToDriver(
                                        sessionId: effectiveSessionId,
                                        driverId: driver.userId,
                                      ));
                                }
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }

        // Default / loading state
        return Align(
          alignment: Alignment.bottomCenter,
          child: const RetrievalRequestSheet(
            message: 'Loading...',
            isLoading: true,
          ),
        );
      },
    );
  }

  List<PassAvailableDriver> _driversFromState(
      PassAvailableDriversState state) {
    if (state is PassAvailableDriversLoaded) return state.drivers;
    if (state is PassingSessionToDriver) return state.drivers;
    if (state is PassToDriverError) return state.drivers;
    return [];
  }

  void _navigateToConfirmArrival(BuildContext context) async {
    final navigator = Navigator.of(context);
    final sessionData = await TokenStorage.getAssignedSessionData();
    if (sessionData != null) {
      try {
        final session = AssignedSession.fromJson(sessionData);
        navigator.push(
          MaterialPageRoute(
            builder: (context) => ConfirmArrivalScreen(
              session: session,
              preventBackNavigation: true,
              acceptTriggeredAt: _acceptTriggeredAt,
              disableConfirmArrivalForSeconds: null,
            ),
          ),
        );
      } catch (_) {}
    }
  }
}
