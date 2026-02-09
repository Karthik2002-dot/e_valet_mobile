import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/assigned_sessions_background/assigned_sessions_background_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_request_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_request_event.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_requesy_state.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/retrieval_request_sheet.dart';

class AssignedSessionSheetLoader extends StatefulWidget {
  const AssignedSessionSheetLoader({super.key});

  @override
  State<AssignedSessionSheetLoader> createState() =>
      _AssignedSessionSheetLoaderState();
}

class _AssignedSessionSheetLoaderState
    extends State<AssignedSessionSheetLoader> {
  bool _isAcceptLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssignedSessionsBackgroundBloc,
        AssignedSessionsBackgroundState>(
      builder: (context, assignedState) {
        if (assignedState is AssignedSessionsBackgroundData) {
          // Never show empty sheet content — when no sessions, parent closes sheet
          if (!assignedState.hasSessions) {
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
              // Defensive: map from backend - try to parse to typed session
              sessionId = rawSession['id']?.toString();
              sessionJson = rawSession;
              // Try to parse the session to get typed object with all fields
              try {
                typedSession = AssignedSession.fromJson(rawSession);
              } catch (e) {
                // If parsing fails, keep sessionJson as raw map
                // This ensures we still have the data even if model parsing fails
              }
            }

            if (sessionId != null) {
              TokenStorage.saveSessionIdFromGetApi(sessionId).catchError((e) {
                // ignore or log
              });
            }
            if (sessionJson != null) {
              TokenStorage.saveAssignedSessionData(sessionJson).catchError((e) {
                // ignore or log
              });
              // Save parkingLocation if present - check both typed session and raw JSON
              String? parkingLocation;
              if (typedSession != null &&
                  typedSession.parkingLocation.isNotEmpty) {
                // Use parkingLocation from typed session if available
                parkingLocation = typedSession.parkingLocation;
              } else if (sessionJson is Map<String, dynamic>) {
                // Fallback to raw JSON if typed session doesn't have it
                final rawLocation = sessionJson['parkingLocation'];
                if (rawLocation != null) {
                  parkingLocation = rawLocation.toString();
                }
              }

              // Save parkingLocation if we found it
              if (parkingLocation != null &&
                  parkingLocation.trim().isNotEmpty) {
                TokenStorage.saveParkingLocation(parkingLocation)
                    .catchError((e) {
                  // ignore or log
                });
              }
            }
          }

          return Align(
            alignment: Alignment.bottomCenter,
            child: BlocProvider(
              create: (context) => RetrivalRequestBloc(),
              child: Builder(
                builder: (blocContext) {
                  return BlocListener<RetrivalRequestBloc,
                      RetrivalRequestState>(
                    listener: (context, state) {
                      if (state is RetrivalRequestLoading) {
                        if (mounted) {
                          setState(() {
                            _isAcceptLoading = true;
                          });
                        }
                      }
                      if (state is RetrivalRequestAccepted) {
                        SnackBars.showSuccessSnackBar(context, state.message);
                        if (mounted) {
                          setState(() {
                            _isAcceptLoading = false;
                          });
                        }
                        Navigator.of(context).pop();
                        _navigateToConfirmArrival(context);
                      } else if (state is RetrivalRequestError) {
                        SnackBars.showErrorSnackBar(context, state.message);
                        if (mounted) {
                          setState(() {
                            _isAcceptLoading = false;
                          });
                        }
                      }
                    },
                    child: RetrievalRequestSheet(
                      // If you make this parameter `AssignedSession?` in the sheet:
                      session: typedSession,
                      message: typedSession == null
                          ? 'No active retrieval requests'
                          : null,
                      isLoading: false,
                      isAcceptLoading: _isAcceptLoading,
                      onAccept: sessionId != null
                          ? () {
                              if (_isAcceptLoading) {
                                return;
                              }
                              setState(() {
                                _isAcceptLoading = true;
                              });
                              TokenStorage.getSessionIdFromGetApi()
                                  .then((storedSessionId) {
                                if (storedSessionId != null &&
                                    storedSessionId.isNotEmpty) {
                                  if (blocContext.mounted) {
                                    blocContext.read<RetrivalRequestBloc>().add(
                                          AcceptRetrivalRequest(
                                              storedSessionId),
                                        );
                                  }
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      _isAcceptLoading = false;
                                    });
                                  }
                                  // log if needed
                                }
                              });
                            }
                          : null,
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

  void _navigateToConfirmArrival(BuildContext context) async {
    final sessionData = await TokenStorage.getAssignedSessionData();
    if (sessionData != null) {
      try {
        final session = AssignedSession.fromJson(sessionData);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ConfirmArrivalScreen(
              session: session,
              preventBackNavigation: true,
            ),
          ),
        );
      } catch (e) {
        // log parse error
      }
    } else {
      // no data found
    }
  }
}
