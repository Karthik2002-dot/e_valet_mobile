import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_valet/valet_kpis_response.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/widgets/valet_kpi_card.dart';

class ValetKpisGrid extends StatelessWidget {
  final ValetKpisResponse? kpis;
  final bool isLoading;

  const ValetKpisGrid({
    super.key,
    this.kpis,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3,
      children: [
        ValetKpiCard(
          value: kpis != null ? '${kpis!.totalValets}' : '0',
          label: TextConstants.totalValets,
          isLoading: isLoading,
        ),
        ValetKpiCard(
          value: kpis != null ? '${kpis!.availableValets}' : '0',
          label: TextConstants.onavailableValets,
          isLoading: isLoading,
        ),
        ValetKpiCard(
          value: kpis != null ? '${kpis!.onDutyValets}' : '0',
          label: TextConstants.onDutyValets,
          isLoading: isLoading,
        ),
        ValetKpiCard(
          value: kpis != null ? '${kpis!.onBreakValets}' : '0',
          label: TextConstants.onBreakValets,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
