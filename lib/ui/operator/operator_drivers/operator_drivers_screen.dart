import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_kpis/valet_kpis_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_kpis/valet_kpis_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_kpis/valet_kpis_state.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_event.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/widgets/valet_kpis_grid.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/widgets/valet_list_view.dart';

class OperatorDriversScreen extends StatefulWidget {
  final Function(VoidCallback)? onRefreshReady;
  final Function(int)? onNavigateToTab;

  const OperatorDriversScreen({
    super.key,
    this.onRefreshReady,
    this.onNavigateToTab,
  });

  @override
  State<OperatorDriversScreen> createState() => _OperatorDriversScreenState();
}

enum ValetFilter { all, available, onDuty, onBreak }

class _OperatorDriversScreenState extends State<OperatorDriversScreen> {
  late ValetKpisBloc _valetKpisBloc;
  late ValetListBloc _valetListBloc;
  final String _outletId = dotenv.env['OUTLET_ID'] ?? '1';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ValetFilter _selectedFilter = ValetFilter.all;

  @override
  void initState() {
    super.initState();
    _valetKpisBloc = ValetKpisBloc();
    _valetKpisBloc.add(FetchValetKpis(outletId: _outletId));
    _valetListBloc = ValetListBloc();
    _valetListBloc.add(FetchValetList(outletId: _outletId));
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    // Provide the refresh method to the parent immediately
    if (widget.onRefreshReady != null) {
      // Call immediately instead of using addPostFrameCallback
      Future.microtask(() {
        widget.onRefreshReady?.call(refresh);
      });
    }
  }

  void refresh() {
    print('OperatorDriversScreen: refresh() called'); // Debug log
    _valetKpisBloc.add(FetchValetKpis(outletId: _outletId));
    _valetListBloc.add(FetchValetList(outletId: _outletId));
    // Reset filter to show all when refreshing
    if (mounted) {
      setState(() {
        _selectedFilter = ValetFilter.all;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _valetKpisBloc.close();
    _valetListBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _valetKpisBloc),
          BlocProvider.value(value: _valetListBloc),
        ],
        child: SafeArea(
          child: SingleChildScrollView(
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
                          labelText: TextConstants.valetDashboardTitle,
                          color: AppColors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.02,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 48), // Align with title text start
                      child: TextComponent(
                        labelText: TextConstants.valetDashboardDescription,
                        color: AppColors.grey,
                        fontSize: MediaQuery.of(context).size.width * 0.013,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                BlocBuilder<ValetKpisBloc, ValetKpisState>(
                  builder: (context, state) {
                    final isLoading = state is ValetKpisLoading;
                    final isLoaded = state is ValetKpisLoaded;

                    if (state is ValetKpisError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextComponent(
                              labelText:
                                  '${TextConstants.errorLabel}: ${state.message}',
                              color: AppColors.error,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _valetKpisBloc.add(
                                  FetchValetKpis(outletId: _outletId),
                                );
                              },
                              child: const TextComponent(
                                labelText: TextConstants.retryButton,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ValetKpisGrid(
                      kpis: isLoaded ? state.kpis : null,
                      isLoading: isLoading,
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: TextConstants.searchByNameOrPhone,
                      hintStyle: TextStyle(
                        color: AppColors.grey,
                        fontSize: MediaQuery.of(context).size.width * 0.013,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: AppColors.grey, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.013,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ValetListView(
                  outletId: _outletId,
                  searchQuery: _searchQuery,
                  statusFilter: _selectedFilter,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
