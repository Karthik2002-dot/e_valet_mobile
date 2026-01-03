import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_request.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/utils/retrieval_request_utils.dart';

class RetrievalRequestCard extends StatelessWidget {
  final RetrievalRequest request;

  const RetrievalRequestCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.015,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.01,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: RetrievalRequestUtils.getPriorityColor(request.waitingTime),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.directions_car,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: Colors.grey,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.width * 0.15,
                  color: Colors.grey[300],
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
                  color: Colors.white,
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
                color: Colors.red,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.008),
              TextComponent(
                labelText: request.waitingTime,
                fontSize: MediaQuery.of(context).size.width * 0.014,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              TextComponent(
                labelText:
                    'Requested at ${RetrievalRequestUtils.formatTime(request.requestedAt)}',
                fontSize: MediaQuery.of(context).size.width * 0.012,
                color: Colors.grey[600] ?? Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
