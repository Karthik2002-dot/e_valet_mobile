import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_car_logs/sortable_header_cell_widget.dart';

enum SortDirection { none, ascending, descending }

class TableHeaderRowWidget extends StatelessWidget {
  final double availableWidth;
  final String sortColumn;
  final SortDirection sortDirection;
  final Function(String) onHeaderTap;
  final IconData? Function(String) getSortIcon;

  const TableHeaderRowWidget({
    super.key,
    required this.availableWidth,
    required this.sortColumn,
    required this.sortDirection,
    required this.onHeaderTap,
    required this.getSortIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: availableWidth,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 12,
            child: SortableHeaderCellWidget(
              text: TextConstants.carLogsTagNumber,
              isActive: sortColumn == TextConstants.carLogsTagNumber,
              sortIcon: getSortIcon(TextConstants.carLogsTagNumber),
              onTap: () => onHeaderTap(TextConstants.carLogsTagNumber),
            ),
          ),
          Expanded(
            flex: 16,
            child: SortableHeaderCellWidget(
              text: TextConstants.carLogsCarStatus,
              isActive: sortColumn == TextConstants.carLogsCarStatus,
              sortIcon: getSortIcon(TextConstants.carLogsCarStatus),
              onTap: () => onHeaderTap(TextConstants.carLogsCarStatus),
            ),
          ),
          Expanded(
            flex: 16,
            child: SortableHeaderCellWidget(
              text: TextConstants.carLogsDuration,
              isActive: sortColumn == TextConstants.carLogsDuration,
              sortIcon: getSortIcon(TextConstants.carLogsDuration),
              onTap: () => onHeaderTap(TextConstants.carLogsDuration),
            ),
          ),
          Expanded(
            flex: 20,
            child: SortableHeaderCellWidget(
              text: TextConstants.carLogsParkLocation,
              isActive: sortColumn == TextConstants.carLogsParkLocation,
              sortIcon: getSortIcon(TextConstants.carLogsParkLocation),
              onTap: () => onHeaderTap(TextConstants.carLogsParkLocation),
            ),
          ),
          Expanded(
            flex: 20,
            child: SortableHeaderCellWidget(
              text: TextConstants.carLogsParkedBy,
              isActive: sortColumn == TextConstants.carLogsParkedBy,
              sortIcon: getSortIcon(TextConstants.carLogsParkedBy),
              onTap: () => onHeaderTap(TextConstants.carLogsParkedBy),
            ),
          ),
          Expanded(
            flex: 16,
            child: SortableHeaderCellWidget(
              text: TextConstants.carLogsParkedAt,
              isActive: sortColumn == TextConstants.carLogsParkedAt,
              sortIcon: getSortIcon(TextConstants.carLogsParkedAt),
              onTap: () => onHeaderTap(TextConstants.carLogsParkedAt),
            ),
          ),
        ],
      ),
    );
  }
}
