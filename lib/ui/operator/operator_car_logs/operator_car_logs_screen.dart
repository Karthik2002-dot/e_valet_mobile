import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_state.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/car_log.dart';
import 'package:niloufer_valet_mobile/utils/time_utils.dart';

enum SortDirection { none, ascending, descending }

class OperatorCarLogsScreen extends StatefulWidget {
  final Function(VoidCallback)? onRefreshReady;
  final Function(int)? onNavigateToTab;

  const OperatorCarLogsScreen({
    super.key,
    this.onRefreshReady,
    this.onNavigateToTab,
  });

  @override
  State<OperatorCarLogsScreen> createState() => _OperatorCarLogsScreenState();
}

class _OperatorCarLogsScreenState extends State<OperatorCarLogsScreen> {
  late CarLogsBloc _carLogsBloc;
  final String _outletId = dotenv.env['OUTLET_ID'] ?? '1';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sorting state
  String _sortColumn = '';
  SortDirection _sortDirection = SortDirection.none;

  // Pagination state
  static const List<int> _pageSizeOptions = [10, 20, 50, 100];
  int _itemsPerPage = 10;
  int _currentPage = 1;
  int _totalItems = 0;

  // Loading state for table
  bool _isTableLoading = false;
  bool _isFetchingData = false; // Prevent multiple simultaneous requests

  @override
  void initState() {
    super.initState();
    _carLogsBloc = CarLogsBloc();
    _isTableLoading = true; // Set loading on initial load
    _fetchCarLogs();

    // Provide the refresh method to the parent
    if (widget.onRefreshReady != null) {
      Future.microtask(() {
        widget.onRefreshReady?.call(refresh);
      });
    }
  }

  void refresh() {
    print('OperatorCarLogsScreen: refresh() called'); // Debug log
    _carLogsBloc.add(FetchCarLogs(
      outletId: _outletId,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _carLogsBloc.close();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _currentPage = 1; // Reset to first page when search is cleared
      _isTableLoading = true;
    });
    _fetchCarLogs();
  }

  void _fetchCarLogs() {
    if (_isFetchingData) return; // Prevent multiple simultaneous requests

    _isFetchingData = true;
    _carLogsBloc.add(FetchCarLogs(
      outletId: _outletId,
      page: _currentPage,
      pageSize: _itemsPerPage,
    ));
  }

  int _getTotalPages() {
    return (_totalItems / _itemsPerPage).ceil();
  }

  List<CarLog> _getFilteredLogs(List<CarLog> logs) {
    if (_searchQuery.isEmpty) {
      return logs;
    }

    final query = _searchQuery.toLowerCase();
    return logs.where((log) {
      return log.tagNumber.toString().toLowerCase().contains(query) ||
          log.displayStatus.toLowerCase().contains(query) ||
          log.parkedBy.name.toLowerCase().contains(query);
    }).toList();
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _isTableLoading = true;
    });
    _fetchCarLogs();
  }

  void _goToFirstPage() {
    _goToPage(1);
  }

  void _goToLastPage() {
    _goToPage(_getTotalPages());
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
    }
  }

  void _goToNextPage() {
    if (_currentPage < _getTotalPages()) {
      _goToPage(_currentPage + 1);
    }
  }

  void _changePageSize(int newSize) {
    setState(() {
      _itemsPerPage = newSize;
      _currentPage = 1; // Reset to first page when page size changes
      _isTableLoading = true;
    });
    _fetchCarLogs();
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
              // Update total items from server response
              _totalItems = state.carLogsResponse.total;
              _currentPage = state.carLogsResponse.page;
              _itemsPerPage = state.carLogsResponse.pageSize;
              _isTableLoading = false; // Reset loading state
              _isFetchingData = false; // Reset fetching flag

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button, title, and description
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              color: AppColors.black,
                              onPressed: () {
                                // Navigate back to dashboard (index 0)
                                widget.onNavigateToTab?.call(0);
                              },
                            ),
                            TextComponent(
                              labelText:
                                  '${TextConstants.carLogsTitle} (${state.carLogsResponse.total})',
                              color: AppColors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                            const Spacer(),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: TextField(
                                controller: _searchController,
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                    _currentPage =
                                        1; // Reset to first page when search changes
                                  });
                                  // For now, keep client-side search since API doesn't support search parameters
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Search by tag, status, or parked by...',
                                  hintStyle: TextStyle(
                                    color: AppColors.grey,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.012,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: AppColors.primary,
                                    size: MediaQuery.of(context).size.width *
                                        0.015,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: AppColors.grey,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.015,
                                          ),
                                          onPressed: _clearSearch,
                                        )
                                      : null,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.01,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.01,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.012,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 0),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 48), // Align with title text start
                          child: TextComponent(
                            labelText: TextConstants.carLogsDescription,
                            color: AppColors.grey,
                            fontSize: MediaQuery.of(context).size.width * 0.013,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (state.carLogsResponse.logs.isEmpty)
                      Expanded(
                        child: Center(
                          child: TextComponent(
                            labelText: 'No car logs available',
                            color: AppColors.grey,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: _isTableLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : SingleChildScrollView(
                                      child: _buildCarLogsTable(
                                          _getFilteredLogs(
                                              state.carLogsResponse.logs)),
                                    ),
                            ),
                            _buildPaginationControls(
                                state.carLogsResponse.logs),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            } else if (state is CarLogsError) {
              _isFetchingData = false; // Reset fetching flag on error
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
                          page: _currentPage,
                          pageSize: _itemsPerPage,
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

      return _sortDirection == SortDirection.ascending
          ? comparison
          : -comparison;
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
          Expanded(flex: 20, child: _buildSortableHeaderCell('Parked By')),
          Expanded(flex: 16, child: _buildSortableHeaderCell('Parked At')),
        ],
      ),
    );
  }

  Widget _buildTableDataRow(CarLog log, int index, double availableWidth) {
    return Container(
      width: availableWidth,
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : AppColors.grey.withOpacity(0.05),
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
          Expanded(
              flex: 16, child: _buildDataCell(_formatDateTime(log.parkedAt))),
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
    return TimeUtils.formatUtcToIstFullDateTime(dateTimeString);
  }

  Widget _buildPaginationControls(List<CarLog> logs) {
    final filteredLogs = _getFilteredLogs(logs);
    final displayTotal =
        _searchQuery.isEmpty ? _totalItems : filteredLogs.length;
    final totalPages = _getTotalPages();

    // Hide pagination when searching (search works on current page only)
    if (_searchQuery.isNotEmpty || totalPages <= 1) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Page size dropdown
            _buildPageSizeDropdown(),

            const Spacer(),

            // Page info
            Text(
              '${(_currentPage - 1) * _itemsPerPage + 1}-${_currentPage * _itemsPerPage > displayTotal ? displayTotal : _currentPage * _itemsPerPage} of $displayTotal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Page size dropdown
          _buildPageSizeDropdown(),

          const Spacer(),

          // First page button (<<) - only show if not on first page
          if (_currentPage > 1)
            IconButton(
              icon: const Text('<<',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onPressed: _goToFirstPage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
            ),

          // Previous page button (<) - only show if not on first page
          if (_currentPage > 1)
            IconButton(
              icon: const Text('<',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onPressed: _goToPreviousPage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
            ),

          // Add spacing between navigation buttons and page numbers
          if (_currentPage > 1) const SizedBox(width: 20),

          // Page numbers
          ..._buildPageNumbers(totalPages),

          // Add spacing between page numbers and navigation buttons
          if (_currentPage < totalPages) const SizedBox(width: 20),

          // Next page button (>) - only show if not on last page
          if (_currentPage < totalPages)
            IconButton(
              icon: const Text('>',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onPressed: _goToNextPage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
            ),

          // Last page button (>>) - only show if not on last page
          if (_currentPage < totalPages)
            IconButton(
              icon: const Text('>>',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onPressed: _goToLastPage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
            ),

          const Spacer(),

          // Page info
          Text(
            '${(_currentPage - 1) * _itemsPerPage + 1}-${_currentPage * _itemsPerPage > _totalItems ? _totalItems : _currentPage * _itemsPerPage} of $_totalItems',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    final widgets = <Widget>[];
    const maxVisiblePages = 5;

    if (totalPages <= maxVisiblePages) {
      // Show all pages if total is small
      for (int i = 1; i <= totalPages; i++) {
        widgets.add(_buildPageButton(i));
      }
    } else {
      // Show pages with ellipsis for large totals
      if (_currentPage <= 3) {
        // Current page is near the beginning
        for (int i = 1; i <= 4; i++) {
          widgets.add(_buildPageButton(i));
        }
        widgets.add(const Text('...', style: TextStyle(fontSize: 14)));
        widgets.add(_buildPageButton(totalPages));
      } else if (_currentPage >= totalPages - 2) {
        // Current page is near the end
        widgets.add(_buildPageButton(1));
        widgets.add(const Text('...', style: TextStyle(fontSize: 14)));
        for (int i = totalPages - 3; i <= totalPages; i++) {
          widgets.add(_buildPageButton(i));
        }
      } else {
        // Current page is in the middle
        widgets.add(_buildPageButton(1));
        widgets.add(const Text('...', style: TextStyle(fontSize: 14)));
        for (int i = _currentPage - 1; i <= _currentPage + 1; i++) {
          widgets.add(_buildPageButton(i));
        }
        widgets.add(const Text('...', style: TextStyle(fontSize: 14)));
        widgets.add(_buildPageButton(totalPages));
      }
    }

    return widgets;
  }

  Widget _buildPageButton(int page) {
    final isSelected = page == _currentPage;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => _goToPage(page),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPageSizeDropdown() {
    return Row(
      children: [
        Text(
          'Show:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: _itemsPerPage,
            onChanged: (int? newValue) {
              if (newValue != null) {
                _changePageSize(newValue);
              }
            },
            items: _pageSizeOptions.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
            underline: const SizedBox.shrink(),
            icon: Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: AppColors.grey,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
