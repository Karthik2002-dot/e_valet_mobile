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

class AssignedSessionSheetLoader extends StatelessWidget {
  const AssignedSessionSheetLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RetrivalRequestBloc()..add(const FetchRetrivalRequests()),
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
        child: FutureBuilder<AssignedSession?>(
          future: AssignedSessionsApiService.fetchFirstAssignedSession(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const RetrievalRequestSheet(isLoading: true);
            }

            if (snapshot.hasError) {
              return RetrievalRequestSheet(
                message: snapshot.error.toString(),
              );
            }

            final assignedSession = snapshot.data;
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

            return BlocBuilder<RetrivalRequestBloc, RetrivalRequestState>(
              builder: (context, state) {
                return RetrievalRequestSheet(
                  session: assignedSession,
                  message: assignedSession == null
                      ? 'No active retrieval requests'
                      : null,
                  isLoading: state is RetrivalRequestLoading,
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
              },
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
