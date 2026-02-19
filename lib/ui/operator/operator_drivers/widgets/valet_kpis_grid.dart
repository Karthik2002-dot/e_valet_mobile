import 'dart:io';

import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_valet/valet_kpis_response.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/widgets/valet_kpi_card.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/operator_drivers_screen.dart';

class ValetKpisGrid extends StatelessWidget {
  final ValetKpisResponse? kpis;
  final bool isLoading;
  final ValetFilter selectedFilter;
  final Function(ValetFilter) onFilterChanged;

  const ValetKpisGrid({
    super.key,
    this.kpis,
    this.isLoading = false,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // iOS only: 2 columns, medium aspect ratio so KPI cards are balanced and content fills space
    final isIOS = Platform.isIOS;
    final crossAxisCount = isIOS ? 2 : 4;
    final childAspectRatio = isIOS ? 2.4 : 2.5;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
      children: [
        ValetKpiCard(
          value: kpis != null ? '${kpis!.totalValets}' : '0',
          label: TextConstants.totalValets,
          isLoading: isLoading,
          isSelected: selectedFilter == ValetFilter.all,
          onTap: () => onFilterChanged(ValetFilter.all),
        ),
        ValetKpiCard(
          value: kpis != null ? '${kpis!.availableValets}' : '0',
          label: TextConstants.onavailableValets,
          isLoading: isLoading,
          isSelected: selectedFilter == ValetFilter.available,
          onTap: () => onFilterChanged(ValetFilter.available),
        ),
        ValetKpiCard(
          value: kpis != null ? '${kpis!.onDutyValets}' : '0',
          label: TextConstants.onDutyValets,
          isLoading: isLoading,
          isSelected: selectedFilter == ValetFilter.onDuty,
          onTap: () => onFilterChanged(ValetFilter.onDuty),
        ),
        ValetKpiCard(
          value: kpis != null ? '${kpis!.onBreakValets}' : '0',
          label: TextConstants.onBreakValets,
          isLoading: isLoading,
          isSelected: selectedFilter == ValetFilter.onBreak,
          onTap: () => onFilterChanged(ValetFilter.onBreak),
        ),
      ],
    );
  }
}
