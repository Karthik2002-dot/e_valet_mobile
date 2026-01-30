import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_available_drivers_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_requests_response.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/skeleton_loader.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/available_drivers_card.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/retrieval_request_card.dart';

class DashboardThreeColumnLayout extends StatefulWidget {
  final RetrievalRequestsResponse retrievalRequests;
  final OperatorAvailableDriversResponse availableDrivers;
  final VoidCallback onAssignmentComplete;
  final bool isLoading;

  const DashboardThreeColumnLayout({
    super.key,
    required this.retrievalRequests,
    required this.availableDrivers,
    required this.onAssignmentComplete,
    this.isLoading = false,
  });

  @override
  State<DashboardThreeColumnLayout> createState() =>
      _DashboardThreeColumnLayoutState();
}

class _DashboardThreeColumnLayoutState
    extends State<DashboardThreeColumnLayout> {
  final ScrollController _retrievalRequestsScrollController =
      ScrollController();

  int _statusOrder(String status) {
    switch (status.toUpperCase()) {
      case 'RETRIEVAL_REQUESTED':
        return 0;
      case 'ASSIGNED':
        return 1;
      case 'ACCEPTED':
        return 2;
      case 'ARRIVED':
        return 3;
      default:
        return 4;
    }
  }

  @override
  void dispose() {
    _retrievalRequestsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Retrieval Requests Column
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextComponent(
                labelText: TextConstants.retrievalRequests,
                color: AppColors.black,
                fontSize: MediaQuery.of(context).size.width * 0.018,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Expanded(
                child: widget.isLoading
                    ? ListView.builder(
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.015,
                            ),
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.01,
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
                              children: [
                                SkeletonLoader(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  borderRadius: 4,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                SkeletonLoader(
                                  height: MediaQuery.of(context).size.height *
                                      0.015,
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  borderRadius: 4,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : widget.retrievalRequests.requests.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 48,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextComponent(
                                  labelText:
                                      TextConstants.noPendingRetrievalRequests,
                                  fontSize: 14,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          )
                        : DragTarget<Object>(
                            onMove: (details) {
                              _handleAutoScroll(details.offset);
                            },
                            onLeave: (data) {
                              // Stop auto-scrolling when drag leaves
                            },
                            builder: (context, candidateData, rejectedData) {
                              final sortedRequests = [
                                ...widget.retrievalRequests.requests
                              ];
                              sortedRequests.sort(
                                (a, b) => _statusOrder(a.status)
                                    .compareTo(_statusOrder(b.status)),
                              );

                              return ListView.builder(
                                controller: _retrievalRequestsScrollController,
                                itemCount: sortedRequests.length,
                                itemBuilder: (context, index) {
                                  final request = sortedRequests[index];
                                  return RetrievalRequestCard(
                                    request: request,
                                    availableDrivers:
                                        widget.availableDrivers.drivers,
                                    onAssignmentComplete:
                                        widget.onAssignmentComplete,
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.02,
        ),
        // Available Drivers Column
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextComponent(
                labelText: TextConstants.availableValets,
                color: AppColors.black,
                fontSize: MediaQuery.of(context).size.width * 0.018,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Expanded(
                child: widget.isLoading
                    ? ListView.builder(
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.015,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.01,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
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
                            child: Row(
                              children: [
                                SkeletonLoader(
                                  height:
                                      MediaQuery.of(context).size.width * 0.05,
                                  width:
                                      MediaQuery.of(context).size.width * 0.05,
                                  borderRadius: 100,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.015,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SkeletonLoader(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        borderRadius: 4,
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.005,
                                      ),
                                      SkeletonLoader(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.012,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                        borderRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                SkeletonLoader(
                                  height: MediaQuery.of(context).size.height *
                                      0.025,
                                  width:
                                      MediaQuery.of(context).size.width * 0.06,
                                  borderRadius: 12,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Builder(
                        builder: (context) {
                          // Filter to only show drivers with 'free' status
                          var freeDrivers = widget.availableDrivers.drivers
                              .where((driver) =>
                                  driver.status.toLowerCase() == 'free')
                              .toList();

                          // Find the recommended driver (who parked the first retrieval request)
                          String? recommendedDriverName;
                          int? recommendedCardNumber;
                          if (widget.retrievalRequests.requests.isNotEmpty) {
                            final firstRequest =
                                widget.retrievalRequests.requests.first;
                            recommendedDriverName = firstRequest.parkedBy.name;
                            recommendedCardNumber = firstRequest.cardNumber;
                            // Sort: recommended driver first, then others
                            freeDrivers.sort((a, b) {
                              if (a.name == recommendedDriverName) return -1;
                              if (b.name == recommendedDriverName) return 1;
                              return 0;
                            });
                          }

                          return freeDrivers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 48,
                                        color: AppColors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      TextComponent(
                                        labelText:
                                            TextConstants.noAvailableDrivers,
                                        fontSize: 14,
                                        color: AppColors.grey,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: freeDrivers.length,
                                  itemBuilder: (context, index) {
                                    final driver = freeDrivers[index];
                                    final isRecommended =
                                        driver.name == recommendedDriverName;
                                    return AvailableDriversCard(
                                      driver: driver,
                                      isRecommended: isRecommended,
                                      recommendedCardNumber:
                                          recommendedCardNumber,
                                    );
                                  },
                                );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleAutoScroll(Offset dragPosition) {
    if (!_retrievalRequestsScrollController.hasClients) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Get the bounds of the scroll area
    final scrollAreaHeight = renderBox.size.height;
    final scrollThreshold = 100.0; // Pixels from edge to trigger scroll
    final scrollSpeed = 10.0; // Pixels to scroll per frame

    // Check if dragging near the top
    if (dragPosition.dy < scrollThreshold) {
      final newOffset = _retrievalRequestsScrollController.offset - scrollSpeed;
      if (newOffset >= 0) {
        _retrievalRequestsScrollController.jumpTo(newOffset);
      }
    }
    // Check if dragging near the bottom
    else if (dragPosition.dy > scrollAreaHeight - scrollThreshold) {
      final maxScroll =
          _retrievalRequestsScrollController.position.maxScrollExtent;
      final newOffset = _retrievalRequestsScrollController.offset + scrollSpeed;
      if (newOffset <= maxScroll) {
        _retrievalRequestsScrollController.jumpTo(newOffset);
      }
    }
  }
}
