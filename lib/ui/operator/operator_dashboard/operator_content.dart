import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/dashboard_kpi_grid.dart';

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
                    return DashboardKpiGrid(kpis: state.kpis);
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
