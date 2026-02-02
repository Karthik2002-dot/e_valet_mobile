import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/kpi_card.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_dashboard_kpis_response.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class DashboardKpiGrid extends StatelessWidget {
  final OperatorDashboardKpisResponse kpis;
  final VoidCallback? onTotalVehiclesParkedTap;
  final VoidCallback? onAvailableValetsTap;

  const DashboardKpiGrid({
    super.key,
    required this.kpis,
    this.onTotalVehiclesParkedTap,
    this.onAvailableValetsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: KpiCard(
            title: TextConstants.availableTags,
            value:
                '${kpis.availableTags.available}/${kpis.availableTags.total}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onAvailableValetsTap,
            child: KpiCard(
              title: TextConstants.availableValets,
              value:
                  '${kpis.availableValets.available}/${kpis.availableValets.total}',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KpiCard(
            title: TextConstants.vehiclesInTransit,
            value: kpis.vehiclesInTransit.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onTotalVehiclesParkedTap,
            child: KpiCard(
              title: TextConstants.totalVehiclesParked,
              value: kpis.totalVehiclesParked.toString(),
            ),
          ),
        ),
      ],
    );
  }
}
