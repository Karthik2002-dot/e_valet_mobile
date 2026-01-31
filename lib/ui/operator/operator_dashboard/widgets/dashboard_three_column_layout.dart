import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_available_drivers_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_requests_response.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/available_drivers_horizontal_section.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/retrieval_request_column.dart';

class DashboardThreeColumnLayout extends StatelessWidget {
  final RetrievalRequestsResponse retrievalRequests;
  final OperatorAvailableDriversResponse availableDrivers;
  final VoidCallback onAssignmentComplete;
  final bool isLoading;

  const DashboardThreeColumnLayout({
    super.key,
    required this.retrievalRequests,
    required this.availableDrivers,
    required this.onAssignmentComplete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Available Drivers (top, horizontal scroll) ---
        AvailableDriversHorizontalSection(
          availableDrivers: availableDrivers,
          retrievalRequests: retrievalRequests,
          isLoading: isLoading,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.025),
        // --- Retrieval Requests (two columns) ---
        TextComponent(
          labelText: TextConstants.retrievalRequests,
          color: AppColors.black,
          fontSize: MediaQuery.of(context).size.width * 0.018,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: RetrievalRequestColumn(
                  retrievalRequests: retrievalRequests,
                  availableDrivers: availableDrivers,
                  onAssignmentComplete: onAssignmentComplete,
                  isLoading: isLoading,
                  isLeftColumn: true,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                flex: 1,
                child: RetrievalRequestColumn(
                  retrievalRequests: retrievalRequests,
                  availableDrivers: availableDrivers,
                  onAssignmentComplete: onAssignmentComplete,
                  isLoading: isLoading,
                  isLeftColumn: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
