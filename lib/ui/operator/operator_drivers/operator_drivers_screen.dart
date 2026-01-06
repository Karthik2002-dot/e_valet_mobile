import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final VoidCallback? onRefresh;

  const OperatorDriversScreen({
    super.key,
    this.onRefresh,
  });

  @override
  State<OperatorDriversScreen> createState() => _OperatorDriversScreenState();
}

class _OperatorDriversScreenState extends State<OperatorDriversScreen> {
  late ValetKpisBloc _valetKpisBloc;
  late ValetListBloc _valetListBloc;
  final String _outletId = '2';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _valetKpisBloc = ValetKpisBloc();
    _valetKpisBloc.add(FetchValetKpis(outletId: _outletId));
    _valetListBloc = ValetListBloc();
    _valetListBloc.add(FetchValetList(outletId: _outletId));
  }

  void refresh() {
    _valetKpisBloc.add(FetchValetKpis(outletId: _outletId));
    _valetListBloc.add(FetchValetList(outletId: _outletId));
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
    return MultiBlocProvider(
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
              TextComponent(
                labelText: TextConstants.valetDashboardTitle,
                color: AppColors.black,
                fontSize: MediaQuery.of(context).size.width * 0.02,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              TextComponent(
                labelText: TextConstants.valetDashboardDescription,
                color: AppColors.grey,
                fontSize: MediaQuery.of(context).size.width * 0.013,
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
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.grey.withOpacity(0.3)),
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
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.grey.withOpacity(0.3)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        // TODO: Implement filter functionality
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ValetListView(outletId: _outletId),
            ],
          ),
        ),
      ),
    );
  }
}
