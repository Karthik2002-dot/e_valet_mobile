import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/kpi_card.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late OperatorDashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = OperatorDashboardBloc();
    // Fetch data when widget initializes
    // TODO: Replace with actual outletId from session/profile
    _dashboardBloc.add(
      const FetchDashboardKpis(
        outletId: '1',
      ),
    );
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextComponent(
                labelText: TextConstants.dashboardOverview,
                color: AppColors.black,
                fontSize: MediaQuery.of(context).size.width * 0.02,
              ),
              const SizedBox(height: 24),
              BlocBuilder<OperatorDashboardBloc, OperatorDashboardState>(
                builder: (context, state) {
                  if (state is OperatorDashboardLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is OperatorDashboardLoaded) {
                    final isPortrait = MediaQuery.of(context).orientation ==
                        Orientation.portrait;

                    return Column(
                      children: [
                        if (isPortrait)
                          // Portrait: 2 cards per row
                          Column(
                            children: [
                              // First Row: Available Tags and Available Valets
                              Row(
                                children: [
                                  Expanded(
                                    child: KpiCard(
                                      title: 'Available Tags',
                                      value:
                                          '${state.kpis.availableTags.available}/${state.kpis.availableTags.total}',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: KpiCard(
                                      title: 'Available Valets',
                                      value:
                                          '${state.kpis.availableValets.available}/${state.kpis.availableValets.total}',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Second Row: Vehicles In Transit and Total Vehicles Parked
                              Row(
                                children: [
                                  Expanded(
                                    child: KpiCard(
                                      title: 'Vehicles In Transit',
                                      value: state.kpis.vehiclesInTransit
                                          .toString(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: KpiCard(
                                      title: 'Total Vehicles Parked',
                                      value: state.kpis.totalVehiclesParked
                                          .toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          // Landscape: all 4 cards in one row
                          Row(
                            children: [
                              Expanded(
                                child: KpiCard(
                                  title: 'Available Tags',
                                  value:
                                      '${state.kpis.availableTags.available}/${state.kpis.availableTags.total}',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: KpiCard(
                                  title: 'Available Valets',
                                  value:
                                      '${state.kpis.availableValets.available}/${state.kpis.availableValets.total}',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: KpiCard(
                                  title: 'Vehicles In Transit',
                                  value:
                                      state.kpis.vehiclesInTransit.toString(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: KpiCard(
                                  title: 'Total Vehicles Parked',
                                  value:
                                      state.kpis.totalVehiclesParked.toString(),
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  } else if (state is OperatorDashboardError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextComponent(
                            labelText:
                                '${TextConstants.errorLabel}: ${state.message}',
                            color: Colors.red,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _dashboardBloc.add(
                                const FetchDashboardKpis(
                                  outletId: '1',
                                ),
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
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
