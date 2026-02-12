import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_available_drivers_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_requests_response.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/skeleton_loader.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/available_drivers_card.dart';

/// Horizontal scrollable section showing available (free) drivers at the top of the dashboard.
class AvailableDriversHorizontalSection extends StatelessWidget {
  final OperatorAvailableDriversResponse availableDrivers;
  final RetrievalRequestsResponse retrievalRequests;
  final bool isLoading;

  const AvailableDriversHorizontalSection({
    super.key,
    required this.availableDrivers,
    required this.retrievalRequests,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextComponent(
          labelText: TextConstants.availableValets,
          color: AppColors.black,
          fontSize: MediaQuery.of(context).size.height * 0.015,
        ),
        const SizedBox(height: 12),
        isLoading
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                child: _buildSkeleton(context),
              )
            : _buildContent(context),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.22,
          margin: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.015,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.01,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
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
            children: [
              SkeletonLoader(
                height: MediaQuery.of(context).size.width * 0.05,
                width: MediaQuery.of(context).size.width * 0.05,
                borderRadius: 100,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.015),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      height: MediaQuery.of(context).size.height * 0.015,
                      width: MediaQuery.of(context).size.width * 0.08,
                      borderRadius: 4,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.005,
                    ),
                    SkeletonLoader(
                      height: MediaQuery.of(context).size.height * 0.008,
                      width: MediaQuery.of(context).size.width * 0.06,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    var freeDrivers = availableDrivers.drivers
        .where((driver) => driver.status.toLowerCase() == 'free')
        .toList();

    String? recommendedDriverName;
    int? recommendedCardNumber;
    if (retrievalRequests.requests.isNotEmpty) {
      final firstRequest = retrievalRequests.requests.first;
      recommendedDriverName = firstRequest.parkedBy.name;
      recommendedCardNumber = firstRequest.cardNumber;
      freeDrivers.sort((a, b) {
        if (a.name == recommendedDriverName) return -1;
        if (b.name == recommendedDriverName) return 1;
        return 0;
      });
    }

    if (freeDrivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 40,
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
      );
    }

    return IntrinsicHeight(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < freeDrivers.length; i++) ...[
              if (i > 0) SizedBox(width: MediaQuery.of(context).size.width * 0.015),
              IntrinsicWidth(
                child: AvailableDriversCard(
                  driver: freeDrivers[i],
                  isRecommended: freeDrivers[i].name == recommendedDriverName,
                  recommendedCardNumber: recommendedCardNumber,
                  compact: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
