import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_state.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/car_log.dart';
import 'package:intl/intl.dart';

enum SortDirection { none, ascending, descending }

class OperatorCarLogsScreen extends StatefulWidget {
  const OperatorCarLogsScreen({super.key});

  @override
  State<OperatorCarLogsScreen> createState() => _OperatorCarLogsScreenState();
}

class _OperatorCarLogsScreenState extends State<OperatorCarLogsScreen> {
  late CarLogsBloc _carLogsBloc;
  final String _outletId = dotenv.env['OUTLET_ID'] ?? '1';

  // Sorting state
  String _sortColumn = '';
  SortDirection _sortDirection = SortDirection.none;

  @override
  void initState() {
    super.initState();
    _carLogsBloc = CarLogsBloc();
    _carLogsBloc.add(FetchCarLogs(
      outletId: _outletId,
    ));
  }

  @override
  void dispose() {
    _carLogsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _carLogsBloc,
      child: SafeArea(
        child: BlocBuilder<CarLogsBloc, CarLogsState>(
          builder: (context, state) {
            if (state is CarLogsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CarLogsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextComponent(
                      labelText: TextConstants.carLogsTitle,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    TextComponent(
                      labelText: TextConstants.carLogsDescription,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 16),
                    TextComponent(
                      labelText: 'Total Logs: ${state.carLogsResponse.total}',
                      color: AppColors.black,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 24),
                    if (state.carLogsResponse.logs.isEmpty)
                      Center(
                        child: TextComponent(
                          labelText: 'No car logs available',
                          color: AppColors.grey,
                        ),
                      )
                    else
                      _buildCarLogsTable(state.carLogsResponse.logs),
                  ],
                ),
              );
            } else if (state is CarLogsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextComponent(
                      labelText: 'Error loading car logs',
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 8),
                    TextComponent(
                      labelText: state.message,
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _carLogsBloc.add(FetchCarLogs(
                          outletId: _outletId,
                        ));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  List<CarLog> _sortLogs(List<CarLog> logs) {
    if (_sortColumn.isEmpty || _sortDirection == SortDirection.none) {
      return logs;
    }

    final sortedLogs = List<CarLog>.from(logs);

    sortedLogs.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (_sortColumn) {
        case 'Tag Number':
          aValue = a.tagNumber;
          bValue = b.tagNumber;
          break;
        case 'Car Status':
          aValue = a.displayStatus;
          bValue = b.displayStatus;
          break;
        case 'Duration':
          aValue = a.duration;
          bValue = b.duration;
          break;
        case 'Park Location':
          aValue = a.parkingLocation;
          bValue = b.parkingLocation;
          break;
        case 'Parked At':
          aValue = DateTime.tryParse(a.parkedAt) ?? DateTime.now();
          bValue = DateTime.tryParse(b.parkedAt) ?? DateTime.now();
          break;
        case 'Parked By':
          aValue = a.parkedBy.name;
          bValue = b.parkedBy.name;
          break;
        default:
          return 0;
      }

      int comparison = 0;
      if (aValue is String && bValue is String) {
        comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is int && bValue is int) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      }

      return _sortDirection == SortDirection.ascending ? comparison : -comparison;
    });

    return sortedLogs;
  }

  void _onHeaderTap(String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        // Cycle through sort directions: none -> ascending -> descending -> none
        switch (_sortDirection) {
          case SortDirection.none:
            _sortDirection = SortDirection.ascending;
            break;
          case SortDirection.ascending:
            _sortDirection = SortDirection.descending;
            break;
          case SortDirection.descending:
            _sortDirection = SortDirection.none;
            _sortColumn = '';
            break;
        }
      } else {
        _sortColumn = columnName;
        _sortDirection = SortDirection.ascending;
      }
    });
  }

  Widget _buildCarLogsTable(List<CarLog> logs) {
    // Sort the logs based on current sorting state
    final sortedLogs = _sortLogs(logs);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: availableWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                _buildTableHeaderRow(availableWidth),
                // Data rows
                ...sortedLogs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final log = entry.value;
                  return _buildTableDataRow(log, index, availableWidth);
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeaderRow(double availableWidth) {
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
          Expanded(flex: 12, child: _buildSortableHeaderCell('Tag Number')),
          Expanded(flex: 16, child: _buildSortableHeaderCell('Car Status')),
          Expanded(flex: 16, child: _buildSortableHeaderCell('Duration')),
          Expanded(flex: 20, child: _buildSortableHeaderCell('Park Location')),
          Expanded(flex: 20, child: _buildSortableHeaderCell('Parked At')),
          Expanded(flex: 16, child: _buildSortableHeaderCell('Parked By')),
        ],
      ),
    );
  }

  Widget _buildTableDataRow(CarLog log, int index, double availableWidth) {
    return Container(
      width: availableWidth,
      decoration: BoxDecoration(
        color: index % 2 == 0 
            ? Colors.white 
            : AppColors.grey.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: AppColors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 12, child: _buildDataCell('${log.tagNumber}')),
          Expanded(flex: 16, child: _buildDataCell(log.displayStatus)),
          Expanded(flex: 16, child: _buildDataCell(log.duration)),
          Expanded(flex: 20, child: _buildDataCell(log.parkingLocation)),
          Expanded(flex: 20, child: _buildDataCell(log.parkedBy.name)),
          Expanded(flex: 16, child: _buildDataCell(_formatDateTime(log.parkedAt))),
        ],
      ),
    );
  }

  Widget _buildSortableHeaderCell(String text) {
    final isActive = _sortColumn == text;
    final sortIcon = _getSortIcon(text);

    return InkWell(
      onTap: () => _onHeaderTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: AppColors.grey.withOpacity(0.3)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextComponent(
                labelText: text,
                color: isActive ? AppColors.primary : AppColors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.left,
              ),
            ),
            if (sortIcon != null) ...[
              const SizedBox(width: 4),
              Icon(
                sortIcon,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }


  IconData? _getSortIcon(String columnName) {
    if (_sortColumn != columnName) return null;

    switch (_sortDirection) {
      case SortDirection.ascending:
        return Icons.arrow_upward;
      case SortDirection.descending:
        return Icons.arrow_downward;
      case SortDirection.none:
        return null;
    }
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.grey.withOpacity(0.3)),
        ),
      ),
      child: TextComponent(
        labelText: text,
        color: AppColors.black,
        fontSize: 13,
        fontWeight: FontWeight.normal,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        textAlign: TextAlign.left,
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}
