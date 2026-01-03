import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/available_drivers.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_available_drivers_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_request.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/utils/driver_utils.dart';

class AvailableDriversCard extends StatelessWidget {
  final AvailableDriver driver;

  const AvailableDriversCard({
    super.key,
    required this.driver,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          12,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with Initials
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.025,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: TextComponent(
              labelText: DriverUtils.getInitials(driver.name),
              fontSize: MediaQuery.of(context).size.width * 0.016,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.015),
          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextComponent(
                  labelText: driver.name,
                  fontSize: MediaQuery.of(context).size.width * 0.016,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.003),
                TextComponent(
                  labelText: driver.phone,
                  fontSize: MediaQuery.of(context).size.width * 0.013,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.012,
              vertical: MediaQuery.of(context).size.height * 0.004,
            ),
            decoration: BoxDecoration(
              color: DriverUtils.getStatusColor(driver.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DriverUtils.getStatusColor(driver.status),
                width: 1,
              ),
            ),
            child: TextComponent(
              labelText: driver.status,
              fontSize: MediaQuery.of(context).size.width * 0.012,
              color: DriverUtils.getStatusColor(driver.status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
