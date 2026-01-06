import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_available_drivers_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_requests_response.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/available_drivers_card.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/retrieval_request_card.dart';

class DashboardThreeColumnLayout extends StatelessWidget {
  final RetrievalRequestsResponse retrievalRequests;
  final OperatorAvailableDriversResponse availableDrivers;
  final VoidCallback onAssignmentComplete;

  const DashboardThreeColumnLayout({
    super.key,
    required this.retrievalRequests,
    required this.availableDrivers,
    required this.onAssignmentComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Retrieval Requests Column
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextComponent(
                labelText: TextConstants.retrievalRequests,
                color: AppColors.black,
                fontSize: MediaQuery.of(context).size.width * 0.018,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Expanded(
                child: retrievalRequests.requests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: AppColors.grey,
                            ),
                            const SizedBox(height: 8),
                            TextComponent(
                              labelText:
                                  TextConstants.noPendingRetrievalRequests,
                              fontSize: 14,
                              color: AppColors.grey,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: retrievalRequests.requests.length,
                        itemBuilder: (context, index) {
                          final request = retrievalRequests.requests[index];
                          return RetrievalRequestCard(
                            request: request,
                            availableDrivers: availableDrivers.drivers,
                            onAssignmentComplete: onAssignmentComplete,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.02,
        ),
        // Available Drivers Column
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextComponent(
                labelText: TextConstants.availableDrivers,
                color: AppColors.black,
                fontSize: MediaQuery.of(context).size.width * 0.018,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Filter to only show drivers with 'free' status
                    final freeDrivers = availableDrivers.drivers
                        .where((driver) =>
                            driver.status.toLowerCase() == 'free')
                        .toList();

                    return freeDrivers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 48,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(height: 8),
                                TextComponent(
                                  labelText: TextConstants.noAvailableDrivers,
                                  fontSize: 14,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: freeDrivers.length,
                            itemBuilder: (context, index) {
                              final driver = freeDrivers[index];
                              return AvailableDriversCard(driver: driver);
                            },
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
