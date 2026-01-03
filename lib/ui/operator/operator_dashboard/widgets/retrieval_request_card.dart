import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/available_drivers.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_request.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/assign_driver_dialog.dart';
import 'package:niloufer_valet_mobile/utils/retrieval_request_utils.dart';

class RetrievalRequestCard extends StatelessWidget {
  final RetrievalRequest request;
  final List<AvailableDriver> availableDrivers;
  final VoidCallback onAssignmentComplete;

  const RetrievalRequestCard({
    super.key,
    required this.request,
    required this.availableDrivers,
    required this.onAssignmentComplete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AssignDriverDialog(
            sessionId: request.sessionId,
            availableDrivers: availableDrivers,
            onAssignmentComplete: onAssignmentComplete,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.015,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: RetrievalRequestUtils.getPriorityColor(request.waitingTime),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                request.vehicle.photo,
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.width * 0.15,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: MediaQuery.of(context).size.width * 0.15,
                    color: AppColors.grey,
                    child: Icon(
                      Icons.directions_car,
                      size: MediaQuery.of(context).size.width * 0.08,
                      color: AppColors.grey,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: MediaQuery.of(context).size.width * 0.15,
                    color: AppColors.grey,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextComponent(
                  labelText: '#${request.cardNumber}',
                  fontSize: MediaQuery.of(context).size.width * 0.022,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.015,
                    vertical: MediaQuery.of(context).size.height * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: RetrievalRequestUtils.getPriorityColor(
                        request.waitingTime),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextComponent(
                    labelText: RetrievalRequestUtils.getPriorityLabel(
                        request.waitingTime),
                    fontSize: MediaQuery.of(context).size.width * 0.014,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.008),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: MediaQuery.of(context).size.width * 0.016,
                  color: AppColors.error,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.008),
                TextComponent(
                  labelText: request.waitingTime,
                  fontSize: MediaQuery.of(context).size.width * 0.014,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                TextComponent(
                  labelText:
                      'Requested at ${RetrievalRequestUtils.formatTime(request.requestedAt)}',
                  fontSize: MediaQuery.of(context).size.width * 0.012,
                  color: AppColors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
