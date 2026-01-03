import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_requests_response.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/retrieval_request_card.dart';

class DashboardThreeColumnLayout extends StatelessWidget {
  final RetrievalRequestsResponse retrievalRequests;

  const DashboardThreeColumnLayout({
    super.key,
    required this.retrievalRequests,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Row(
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
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              TextComponent(
                                labelText: 'No pending retrieval requests',
                                fontSize: 14,
                                color: Colors.grey[600] ?? Colors.grey,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: retrievalRequests.requests.length,
                          itemBuilder: (context, index) {
                            final request = retrievalRequests.requests[index];
                            return RetrievalRequestCard(request: request);
                          },
                        ),
                ),
              ],
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextComponent(
                        labelText: 'Coming soon',
                        color: Colors.grey[600] ?? Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          // Digital Key Rack Column
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextComponent(
                  labelText: TextConstants.digitalKeyRack,
                  color: AppColors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.018,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextComponent(
                        labelText: 'Coming soon',
                        color: Colors.grey[600] ?? Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
