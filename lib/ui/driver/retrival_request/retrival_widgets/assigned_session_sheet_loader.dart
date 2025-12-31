import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/assigned_sessions_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_request_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_request_event.dart';
import 'package:niloufer_valet_mobile/bloc/retrival_request/retrival_requesy_state.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/retrieval_request_sheet.dart';

class AssignedSessionSheetLoader extends StatelessWidget {
  const AssignedSessionSheetLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RetrivalRequestBloc()..add(const FetchRetrivalRequests()),
      child: BlocListener<RetrivalRequestBloc, RetrivalRequestState>(
        listener: (context, state) {
          if (state is RetrivalRequestAccepted) {
            print('Accept API successful! Message: ${state.message}');
            SnackBars.showSuccessSnackBar(context, state.message);
            // Close the bottom sheet after successful acceptance
            Navigator.of(context).pop();
          } else if (state is RetrivalRequestError) {
            print('Accept API failed! Error: ${state.message}');
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
              print('Error in FutureBuilder: ${snapshot.error}');
              return RetrievalRequestSheet(
                message: snapshot.error.toString(),
              );
            }

            final assignedSession = snapshot.data;
            print('Assigned session data: $assignedSession');

            return BlocBuilder<RetrivalRequestBloc, RetrivalRequestState>(
              builder: (context, state) {
                return RetrievalRequestSheet(
                  session: assignedSession,
                  message: assignedSession == null ? 'No active retrieval requests' : null,
                  isLoading: state is RetrivalRequestLoading,
                  onAccept: assignedSession != null ? () {
                    print('Accept button clicked for session ID: ${assignedSession.id}');
                    context.read<RetrivalRequestBloc>().add(
                      AcceptRetrivalRequest(assignedSession.id),
                    );
                  } : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
