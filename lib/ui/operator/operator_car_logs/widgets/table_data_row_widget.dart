import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/car_log.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_car_logs/widgets/data_cell_widget.dart';
import 'package:niloufer_valet_mobile/utils/time_utils.dart';

class TableDataRowWidget extends StatelessWidget {
  final CarLog log;
  final int index;
  final double availableWidth;
  final VoidCallback? onTap;

  const TableDataRowWidget({
    super.key,
    required this.log,
    required this.index,
    required this.availableWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: availableWidth,
        decoration: BoxDecoration(
          color: index % 2 == 0
              ? AppColors.white
              : AppColors.grey.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(color: AppColors.grey.withOpacity(0.3)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 12, child: DataCellWidget(text: '${log.tagNumber}')),
            Expanded(flex: 16, child: DataCellWidget(text: log.displayStatus)),
            Expanded(flex: 16, child: DataCellWidget(text: log.duration)),
            Expanded(
                flex: 20, child: DataCellWidget(text: log.parkingLocation)),
            Expanded(flex: 20, child: DataCellWidget(text: log.parkedBy.name)),
            Expanded(
              flex: 16,
              child: DataCellWidget(
                  text: TimeUtils.formatUtcToIstFullDateTime(log.parkedAt)),
            ),
            Expanded(
              flex: 16,
              child: DataCellWidget(
                text: log.handoveredAt.isEmpty
                    ? ''
                    : TimeUtils.formatUtcToIstFullDateTime(log.handoveredAt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
