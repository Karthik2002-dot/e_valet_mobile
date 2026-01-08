import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/assigned_sessions_api_service.dart';
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
  Timer? _pollingTimer;
  RetrivalRequestBloc? _bloc;
  List<dynamic>?
      _lastSessions; // Track last sessions to avoid unnecessary updates

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling(RetrivalRequestBloc bloc) {
    _bloc = bloc; // Store bloc reference
    // Cancel existing timer if any
    _pollingTimer?.cancel();

    // Start polling every 2 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _pollAssignedSessions();
    });
  }

  Future<void> _pollAssignedSessions() async {
    try {
      final sessions = await AssignedSessionsApiService.fetchAssignedSessions();

      // Only update UI if sessions data has actually changed
      if (_hasSessionsChanged(sessions)) {
        _lastSessions = List.from(sessions); // Store copy of new sessions

        // Update the UI with new data silently (no loading state shown)
        if (mounted && _bloc != null) {
          _bloc!.add(UpdateAssignedSessions(sessions));
        }
      }

      // Restart the timer when we get data
      _startPolling(_bloc!);
    } catch (e) {
      print('❌ Failed to poll assigned sessions: $e');
      // Even on error, restart the timer to continue polling
      if (_bloc != null) {
        _startPolling(_bloc!);
      }
    }
  }

  bool _hasSessionsChanged(List<dynamic> newSessions) {
    // If we don't have previous data, consider it changed
    if (_lastSessions == null) return true;

    // If lengths are different, data changed
    if (_lastSessions!.length != newSessions.length) return true;

    // Compare session IDs to check if data actually changed
    for (int i = 0; i < newSessions.length; i++) {
      if (newSessions[i].id != _lastSessions![i].id) {
        return true;
      }
    }

    // Data is the same
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = RetrivalRequestBloc()..add(const FetchRetrivalRequests());
        // Start polling immediately with the bloc reference
        _startPolling(bloc);
        return bloc;
      },
      child: BlocListener<RetrivalRequestBloc, RetrivalRequestState>(
        listener: (context, state) {
          if (state is RetrivalRequestAccepted) {
            SnackBars.showSuccessSnackBar(context, state.message);
            // Close the bottom sheet after successful acceptance
            Navigator.of(context).pop();
            // Navigate to confirm arrival screen with stored session data
            _navigateToConfirmArrival(context);
          } else if (state is RetrivalRequestError) {
            print('❌ Accept API failed! Error: ${state.message}');
            SnackBars.showErrorSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<RetrivalRequestBloc, RetrivalRequestState>(
          builder: (context, state) {
            // Handle different states
            if (state is RetrivalRequestLoading) {
              return const RetrievalRequestSheet(isLoading: true);
            }

            if (state is RetrivalRequestError) {
              return RetrievalRequestSheet(
                message: state.message,
              );
            }

            if (state is RetrivalRequestLoaded) {
              final assignedSession =
                  state.sessions.isNotEmpty ? state.sessions.first : null;

              if (assignedSession != null) {
                // Store the sessionId from GET API in shared preferences
                TokenStorage.saveSessionIdFromGetApi(assignedSession.id)
                    .catchError((error) {
                  print('❌ Failed to store sessionId from GET API: $error');
                });

                // Store the full session data for use in confirm arrival screen
                TokenStorage.saveAssignedSessionData(assignedSession.toJson())
                    .catchError((error) {
                  print('❌ Failed to store assigned session data: $error');
                });
              }

              return RetrievalRequestSheet(
                session: assignedSession,
                message: assignedSession == null
                    ? 'No active retrieval requests'
                    : null,
                isLoading: false, // No loading since updates happen silently
                onAccept: assignedSession != null
                    ? () {
                        // Get the stored sessionId from GET API from shared preferences
                        TokenStorage.getSessionIdFromGetApi()
                            .then((storedSessionId) {
                          if (storedSessionId != null &&
                              storedSessionId.isNotEmpty) {
                            if (context.mounted) {
                              context.read<RetrivalRequestBloc>().add(
                                    AcceptRetrivalRequest(storedSessionId),
                                  );
                            }
                          } else {
                            print(
                                '❌ No stored sessionId from GET API found in shared preferences');
                          }
                        });
                      }
                    : null,
              );
            }

            // Default case for other states
            return const RetrievalRequestSheet(
              message: 'Loading...',
              isLoading: true,
            );
          },
        ),
      ),
    );
  }

  void _navigateToConfirmArrival(BuildContext context) async {
    // Get stored session data
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
        print('❌ Error parsing session data: $e');
      }
    } else {
      print('❌ No session data found in shared preferences');
    }
  }
}
