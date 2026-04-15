import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/assigned_sessions_background/assigned_sessions_background_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/pass_available_drivers/pass_available_drivers_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/pass_available_drivers/pass_available_drivers_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/pass_available_drivers/pass_available_drivers_state.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_request_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_request_event.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_requesy_state.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/park_flow_signals.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/retrieval_request_sheet.dart';
import 'package:niloufer_valet_mobile/services/vibration_controller.dart';

/// Session id for one queue entry (same rules as [AssignedSessionsBackgroundBloc]).
String? sessionIdOfQueueEntry(dynamic s) {
  if (s is AssignedSession) {
    final x = s.id.trim();
    return x.isNotEmpty ? x : null;
  }
  if (s is Map<String, dynamic>) {
    final raw = (s['sessionId'] ?? s['id'])?.toString().trim();
    if (raw != null && raw.isNotEmpty) return raw;
  }
  return null;
}

/// Next retrieval row to show: first FIFO item not in collect-keys-in-transit ack.
/// When the head is acked (in-transit accept done) but other assignments remain, this surfaces them.
dynamic firstQueueEntryVisibleForRetrievalSheet(
  List<dynamic> sessions, {
  String? excludedSessionId,
}) {
  final excluded = excludedSessionId?.trim() ?? '';
  for (final s in sessions) {
    final id = sessionIdOfQueueEntry(s);
    if (id == null || id.isEmpty) continue;
    if (excluded.isNotEmpty && id.trim() == excluded) continue;
    if (!TokenStorage.collectKeysInTransitAckContainsSync(id)) return s;
  }
  return null;
}

/// Display key for the row actually shown (skips acked head rows).
String firstQueueVisibleDisplayKey(
  List<dynamic> sessions, {
  String? excludedSessionId,
}) {
  final v = firstQueueEntryVisibleForRetrievalSheet(
    sessions,
    excludedSessionId: excludedSessionId,
  );
  if (v == null) return '';
  return AssignedSessionsBackgroundBloc.displayKeyOfFirstSession([v]);
}

class AssignedSessionSheetLoader extends StatefulWidget {
  final bool keepCurrentFlowOnAccept;
  final String? excludedSessionId;

  const AssignedSessionSheetLoader({
    super.key,
    this.keepCurrentFlowOnAccept = false,
    this.excludedSessionId,
  });

  @override
  State<AssignedSessionSheetLoader> createState() =>
      _AssignedSessionSheetLoaderState();
}

class _AssignedSessionSheetLoaderState
    extends State<AssignedSessionSheetLoader> {
  bool _isAcceptLoading = false;
  DateTime? _acceptTriggeredAt;
  String? _passErrorMessage;

  void _closeSheetAfterFrame(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      }
    });
  }

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
        // Rebuild when queue ids change OR first row display (photo) changes.
        if (AssignedSessionsBackgroundBloc.orderedSessionIdsSignature(
                previous.sessions) !=
            AssignedSessionsBackgroundBloc.orderedSessionIdsSignature(
                current.sessions)) {
          return true;
        }
        return firstQueueVisibleDisplayKey(
              previous.sessions,
              excludedSessionId: widget.excludedSessionId,
            ) !=
            firstQueueVisibleDisplayKey(
              current.sessions,
              excludedSessionId: widget.excludedSessionId,
            );
      },
      builder: (context, assignedState) {
        if (assignedState is AssignedSessionsBackgroundData) {
          if (!assignedState.hasSessions) {
            VibrationController.stop();
            return const SizedBox.shrink();
          }
          final rawSession = firstQueueEntryVisibleForRetrievalSheet(
            assignedState.sessions,
            excludedSessionId: widget.excludedSessionId,
          );
          if (rawSession == null) {
            VibrationController.stop();
            _closeSheetAfterFrame(context);
            return const SizedBox.shrink();
          }

          AssignedSession? typedSession;
          String? sessionId;
          dynamic sessionJson;

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
            TokenStorage.saveAssignedSessionData(sessionJson)
                .catchError((_) {});
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
                            final ids = state.acceptedIds.isNotEmpty
                                ? state.acceptedIds
                                : (effectiveSessionId != null
                                    ? [effectiveSessionId]
                                    : <String>[]);
                            final skipRetrievalNext = ids.isNotEmpty &&
                                _isInTransitParkFlow(context, ids.first);
                            final shouldKeepCurrentFlow = skipRetrievalNext ||
                                widget.keepCurrentFlowOnAccept;
                            if (shouldKeepCurrentFlow) {
                              for (final sid in ids) {
                                TokenStorage.saveCollectKeysInTransitAckSync(
                                    sid);
                              }
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } else {
                              Navigator.of(context).pop();
                              _navigateToConfirmArrival(context);
                            }
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
                            if (mounted) {
                              setState(() => _passErrorMessage = null);
                            }
                            print(
                                '[PASS UI] Pass success received, closing bottom sheet.');
                            SnackBars.showSuccessSnackBar(
                                context, state.message);
                            // Close the bottom sheet — session has been passed
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          } else if (state is PassToDriverError) {
                            SnackBars.showErrorSnackBar(context, state.message);
                            if (mounted) {
                              setState(() => _passErrorMessage = state.message);
                            }
                          }
                        },
                      ),
                    ],
                    child: BlocBuilder<PassAvailableDriversBloc,
                        PassAvailableDriversState>(
                      builder: (context, passState) {
                        final isPassing = passState is PassingSessionToDriver;
                        final actionsLocked = _isAcceptLoading || isPassing;

                        return RetrievalRequestSheet(
                          session: typedSession,
                          message: typedSession == null
                              ? 'No active retrieval requests'
                              : null,
                          isLoading: false,
                          isAcceptLoading: _isAcceptLoading,
                          passErrorMessage: _passErrorMessage,
                          onAccept: canAccept
                              ? () {
                                  if (actionsLocked) return;
                                  VibrationController.stop();
                                  setState(() {
                                    _isAcceptLoading = true;
                                    _acceptTriggeredAt = DateTime.now();
                                  });
                                  if (blocContext.mounted) {
                                    blocContext.read<RetrivalRequestBloc>().add(
                                          AcceptRetrivalRequest(
                                            effectiveSessionId,
                                            assignedSession: typedSession,
                                          ),
                                        );
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
                          // Pass (no driver selection UI)
                          isPassing: isPassing,
                          onPass: (effectiveSessionId != null && !actionsLocked)
                              ? () {
                                  // Clear any previous pass error once user retries.
                                  if (mounted) {
                                    setState(() => _passErrorMessage = null);
                                  }
                                  print(
                                      '[PASS UI] Pass button tapped for session: $effectiveSessionId');
                                  VibrationController.stop();
                                  blocContext
                                      .read<PassAvailableDriversBloc>()
                                      .add(PassSessionToDriver(
                                        sessionId: effectiveSessionId,
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

  /// Park / camera flow: after accept API succeeds, skip Confirm Arrival and
  /// return to the previous screen only (Hive flags that for [driver_home] too).
  bool _isInTransitParkFlow(BuildContext context, String retrievalSessionId) {
    try {
      // User is on car photo / camera stack — retrieval must not stack Confirm Arrival
      // on top (popping would return here incorrectly).
      if (ParkFlowSignals.isCarPhotoParkFlowActive) {
        return true;
      }
      final hiveParking = TokenStorage.getSessionIdSync();
      if (hiveParking != null &&
          hiveParking.isNotEmpty &&
          hiveParking == retrievalSessionId) {
        return true;
      }
      final menu = context.read<DriverMenuBloc>().state;
      if (menu is! DriverHomeLoaded || menu.pendingSessions == null) {
        return false;
      }
      final pending = menu.pendingSessions!;
      if (!pending.hasCheckedInSession) return false;
      final checked = pending.checkedInSession;
      return checked != null && checked.sessionId == retrievalSessionId;
    } catch (_) {
      return false;
    }
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
