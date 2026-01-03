import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_request.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

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
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor(request.waitingTime),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              request.vehicle.photo,
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.width * 0.15,
              fit: BoxFit.cover,
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
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          // Request Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        color: _getPriorityColor(request.waitingTime),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextComponent(
                        labelText: _getPriorityLabel(request.waitingTime),
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.015,
                        vertical: MediaQuery.of(context).size.height * 0.003,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: MediaQuery.of(context).size.width * 0.016,
                            color: Colors.green,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.005),
                          TextComponent(
                            labelText: request.requestType,
                            fontSize: MediaQuery.of(context).size.width * 0.014,
                            color: Colors.green[700] ?? Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
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
                          'Requested at ${_formatTime(request.requestedAt)}',
                      fontSize: MediaQuery.of(context).size.width * 0.012,
                      color: Colors.grey[600] ?? Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String waitingTime) {
    // Extract minutes from waiting time string like "93mins"
    final minutesStr = waitingTime.replaceAll(RegExp(r'[^0-9]'), '');
    final minutes = int.tryParse(minutesStr) ?? 0;

    if (minutes >= 30) {
      return Colors.red;
    } else if (minutes >= 15) {
      return Colors.orange;
    }
    return Colors.green;
  }

  String _getPriorityLabel(String waitingTime) {
    final minutesStr = waitingTime.replaceAll(RegExp(r'[^0-9]'), '');
    final minutes = int.tryParse(minutesStr) ?? 0;

    if (minutes >= 30) {
      return 'High';
    } else if (minutes >= 15) {
      return 'Medium';
    }
    return 'Low';
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
