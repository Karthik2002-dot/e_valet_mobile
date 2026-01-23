import 'dart:async';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssignedSessionsBackgroundBloc,
        AssignedSessionsBackgroundState>(
      builder: (context, assignedState) {
        if (assignedState is AssignedSessionsBackgroundData) {
          final rawSession = assignedState.sessions.isNotEmpty
              ? assignedState.sessions.first
              : null;

          AssignedSession? typedSession;
          String? sessionId;
          dynamic sessionJson;

          if (rawSession != null) {
            if (rawSession is AssignedSession) {
              typedSession = rawSession;
              sessionId = rawSession.id;
              sessionJson = rawSession.toJson();
            } else if (rawSession is Map<String, dynamic>) {
              // Defensive: map from backend
              sessionId = rawSession['id']?.toString();
              sessionJson = rawSession;
              // Optionally:
              // typedSession = AssignedSession.fromJson(rawSession);
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
              // Save parkingLocation if present
              final parkingLocation = sessionJson['parkingLocation'];
              if (parkingLocation != null &&
                  parkingLocation.toString().trim().isNotEmpty) {
                TokenStorage.saveParkingLocation(parkingLocation.toString())
                    .catchError((e) {
                  // ignore or log
                });
              }
            }
          }

          return BlocProvider(
            create: (context) => RetrivalRequestBloc(),
            child: Builder(
              builder: (blocContext) {
                return BlocListener<RetrivalRequestBloc, RetrivalRequestState>(
                  listener: (context, state) {
                    if (state is RetrivalRequestAccepted) {
                      SnackBars.showSuccessSnackBar(context, state.message);
                      Navigator.of(context).pop();
                      _navigateToConfirmArrival(context);
                    } else if (state is RetrivalRequestError) {
                      SnackBars.showErrorSnackBar(context, state.message);
                    }
                  },
                  child: RetrievalRequestSheet(
                    // If you make this parameter `AssignedSession?` in the sheet:
                    session: typedSession,
                    message: typedSession == null
                        ? 'No active retrieval requests'
                        : null,
                    isLoading: false,
                    onAccept: sessionId != null
                        ? () {
                            TokenStorage.getSessionIdFromGetApi()
                                .then((storedSessionId) {
                              if (storedSessionId != null &&
                                  storedSessionId.isNotEmpty) {
                                if (blocContext.mounted) {
                                  blocContext.read<RetrivalRequestBloc>().add(
                                        AcceptRetrivalRequest(storedSessionId),
                                      );
                                }
                              } else {
                                // log if needed
                              }
                            });
                          }
                        : null,
                  ),
                );
              },
            ),
          );
        }

        // Default / loading state
        return const RetrievalRequestSheet(
          message: 'Loading...',
          isLoading: true,
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
            builder: (context) => ConfirmArrivalScreen(session: session),
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
