import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/api/driver/assigned_sessions_api_service.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/retrieval_request_sheet.dart';

class AssignedSessionSheetLoader extends StatelessWidget {
  const AssignedSessionSheetLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssignedSession?>(
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
        return RetrievalRequestSheet(
          session: assignedSession,
          message:
              assignedSession == null ? 'No active retrieval requests' : null,
        );
      },
    );
  }
}
