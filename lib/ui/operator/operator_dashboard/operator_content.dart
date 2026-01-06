import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/skeleton_loader.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/dashboard_kpi_grid.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/dashboard_three_column_layout.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/manual_request_widget.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_available_drivers_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_requests_response.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late OperatorDashboardBloc _dashboardBloc;
  final String _outletId = '2';

  @override
  void initState() {
    super.initState();

    // Get WebSocketBloc from context if available
    final webSocketBloc = context.read<WebSocketBloc?>();

    // Initialize OperatorDashboardBloc with WebSocketBloc for real-time updates
    _dashboardBloc = OperatorDashboardBloc(
      webSocketBloc: webSocketBloc,
      outletId: _outletId,
    );

    // Fetch data when widget initializes
    _dashboardBloc.add(
      FetchDashboardKpis(
        outletId: _outletId,
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
        child: Padding(
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
              Expanded(
                child:
                    BlocBuilder<OperatorDashboardBloc, OperatorDashboardState>(
                  builder: (context, state) {
                    final isLoading = state is OperatorDashboardLoading;
                    final isLoaded = state is OperatorDashboardLoaded;

                    if (isLoading) {
                      // Show skeleton loaders for KPIs and columns
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KPI Skeleton Grid
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 4,
                            crossAxisSpacing: MediaQuery.of(context).size.width * 0.02,
                            mainAxisSpacing: MediaQuery.of(context).size.height * 0.02,
                            childAspectRatio: 2.5,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(
                              4,
                              (index) => Container(
                                padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.015,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SkeletonLoader(
                                      height: MediaQuery.of(context).size.height * 0.025,
                                      width: MediaQuery.of(context).size.width * 0.05,
                                      borderRadius: 4,
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                    SkeletonLoader(
                                      height: MediaQuery.of(context).size.height * 0.015,
                                      width: MediaQuery.of(context).size.width * 0.08,
                                      borderRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Expanded(
                            child: DashboardThreeColumnLayout(
                              retrievalRequests: RetrievalRequestsResponse(requests: []),
                              availableDrivers: OperatorAvailableDriversResponse(drivers: []),
                              onAssignmentComplete: () {},
                              isLoading: true,
                            ),
                          ),
                        ],
                      );
                    } else if (isLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DashboardKpiGrid(kpis: state.kpis),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Expanded(
                            child: DashboardThreeColumnLayout(
                              retrievalRequests: state.retrievalRequests,
                              availableDrivers: state.availableDrivers,
                              onAssignmentComplete: () {
                                // Refresh the dashboard
                                _dashboardBloc.add(
                                  FetchDashboardKpis(
                                    outletId: _outletId,
                                  ),
                                );
                              },
                              isLoading: false,
                            ),
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
                              color: AppColors.error,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _dashboardBloc.add(
                                  FetchDashboardKpis(
                                    outletId: _outletId,
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
              ),
              ManualRequestWidget(
                onRequestCreated: () {
                  // Refresh the dashboard
                  _dashboardBloc.add(
                    FetchDashboardKpis(
                      outletId: _outletId,
                    ),
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
