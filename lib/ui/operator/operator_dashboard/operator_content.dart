import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:niloufer_valet_mobile/services/notification/text_to_speech_service.dart';

class DashboardContent extends StatefulWidget {
  final void Function(VoidCallback)? onRefreshReady;
  final void Function(int)? onNavigateToTab;

  const DashboardContent({
    super.key,
    this.onRefreshReady,
    this.onNavigateToTab,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late OperatorDashboardBloc _dashboardBloc;
  final String _outletId = dotenv.env['OUTLET_ID'] ?? '1';
  final TextToSpeechService _ttsService = TextToSpeechService();
  final Set<String> _knownRequestIds = <String>{};
  final List<String> _ttsQueue = <String>[];
  final Duration _ttsPause = const Duration(milliseconds: 500);
  bool _isSpeaking = false;
  bool _hasLoadedOnce = false;

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

    // Expose silent refresh method to parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRefreshReady?.call(_silentRefresh);
    });
  }

  void _silentRefresh() {
    _dashboardBloc.add(
      RefreshDashboardKpisSilently(
        outletId: _outletId,
        refreshKpis: true,
        refreshDrivers: true,
        refreshRequests: true,
      ),
    );
  }

  void _handleRetrievalRequestUpdates(
    RetrievalRequestsResponse retrievalRequests,
  ) {
    final currentIds =
        retrievalRequests.requests.map((request) => request.sessionId).toSet();

    if (!_hasLoadedOnce) {
      _knownRequestIds
        ..clear()
        ..addAll(currentIds);
      _hasLoadedOnce = true;
      return;
    }

    final newRequests = retrievalRequests.requests.where((request) {
      if (_knownRequestIds.contains(request.sessionId)) {
        return false;
      }
      return request.status.toUpperCase() == 'RETRIEVAL_REQUESTED';
    }).toList();

    _knownRequestIds
      ..clear()
      ..addAll(currentIds);

    if (newRequests.isEmpty) return;

    final announcements =
        newRequests.map((request) => 'Card ${request.cardNumber}').toList();
    _enqueueAnnouncements(announcements);
  }

  void _enqueueAnnouncements(List<String> announcements) {
    _ttsQueue.addAll(announcements);
    _processTtsQueue();
  }

  Future<void> _processTtsQueue() async {
    if (_isSpeaking || _ttsQueue.isEmpty) return;
    _isSpeaking = true;
    await _ttsService.stop();

    while (_ttsQueue.isNotEmpty) {
      final announcement = _ttsQueue.removeAt(0);
      await _ttsService.speak(announcement);
      if (_ttsQueue.isNotEmpty) {
        await Future.delayed(_ttsPause);
      }
    }

    _isSpeaking = false;
  }

  Widget _buildKpiSkeletonCard(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonLoader(
              height: MediaQuery.of(context).size.height * 0.012,
              width: MediaQuery.of(context).size.width * 0.12,
              borderRadius: 4,
            ),
            const SizedBox(height: 8),
            SkeletonLoader(
              height: MediaQuery.of(context).size.height * 0.015,
              width: MediaQuery.of(context).size.width * 0.08,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.stop();
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
                fontSize: MediaQuery.of(context).size.height * 0.015,
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    BlocConsumer<OperatorDashboardBloc, OperatorDashboardState>(
                  listener: (context, state) {
                    if (state is OperatorDashboardLoaded) {
                      _handleRetrievalRequestUpdates(state.retrievalRequests);
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is OperatorDashboardLoading;
                    final isLoaded = state is OperatorDashboardLoaded;

                    if (isLoading) {
                      // Show skeleton loaders matching KPI card pattern (Row of 4 cards)
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildKpiSkeletonCard(context),
                              const SizedBox(width: 12),
                              _buildKpiSkeletonCard(context),
                              const SizedBox(width: 12),
                              _buildKpiSkeletonCard(context),
                              const SizedBox(width: 12),
                              _buildKpiSkeletonCard(context),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Expanded(
                            child: DashboardThreeColumnLayout(
                              retrievalRequests:
                                  RetrievalRequestsResponse(requests: []),
                              availableDrivers:
                                  OperatorAvailableDriversResponse(drivers: []),
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
                          DashboardKpiGrid(
                            kpis: state.kpis,
                            onAvailableValetsTap: () {
                              // change index to whatever your Valets screen index is
                              widget.onNavigateToTab?.call(2);
                            },
                            onTotalVehiclesParkedTap: () {
                              // change index to whatever your Parking screen index is
                              widget.onNavigateToTab?.call(1);
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015,
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
