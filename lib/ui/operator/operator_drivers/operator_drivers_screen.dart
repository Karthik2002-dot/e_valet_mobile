import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/valet_kpis_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/valet_kpis_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/valet_kpis_state.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/widgets/valet_kpi_card.dart';

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
  final String _outletId = '2';

  @override
  void initState() {
    super.initState();
    _valetKpisBloc = ValetKpisBloc();
    _valetKpisBloc.add(FetchValetKpis(outletId: _outletId));
  }

  void refresh() {
    _valetKpisBloc.add(FetchValetKpis(outletId: _outletId));
  }

  @override
  void dispose() {
    _valetKpisBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _valetKpisBloc,
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
                            labelText: 'Error: ${state.message}',
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
                              labelText: 'Retry',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2,
                    children: [
                      ValetKpiCard(
                        value: isLoaded ? '${state.kpis.totalValets}' : '0',
                        label: TextConstants.totalValets,
                        isLoading: isLoading,
                      ),
                      ValetKpiCard(
                        value: isLoaded ? '${state.kpis.availableValets}' : '0',
                        label: TextConstants.onavailableValets,
                        isLoading: isLoading,
                      ),
                      ValetKpiCard(
                        value: isLoaded ? '${state.kpis.onDutyValets}' : '0',
                        label: TextConstants.onDutyValets,
                        isLoading: isLoading,
                      ),
                      ValetKpiCard(
                        value: isLoaded ? '${state.kpis.onBreakValets}' : '0',
                        label: TextConstants.onBreakValets,
                        isLoading: isLoading,
                      ),
                      ValetKpiCard(
                        value: isLoaded ? '${state.kpis.offlineValets}' : '0',
                        label: TextConstants.offlineValets,
                        isLoading: isLoading,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
