import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_state.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/available_drivers.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_request.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/utils/retrieval_request_utils.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/assignment_confirmation_dialog.dart';

class RetrievalRequestCard extends StatefulWidget {
  final RetrievalRequest request;
  final List<AvailableDriver> availableDrivers;
  final VoidCallback onAssignmentComplete;

  const RetrievalRequestCard({
    super.key,
    required this.request,
    required this.availableDrivers,
    required this.onAssignmentComplete,
  });

  @override
  State<RetrievalRequestCard> createState() => _RetrievalRequestCardState();
}

class _RetrievalRequestCardState extends State<RetrievalRequestCard> {
  bool _isDraggingOver = false;

  void _showAssignmentDialog(AvailableDriver driver) {
    final dashboardBloc = context.read<OperatorDashboardBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          BlocListener<OperatorDashboardBloc, OperatorDashboardState>(
        bloc: dashboardBloc,
        listener: (context, state) {
          if (state is AssignmentSuccess) {
            Navigator.pop(dialogContext);
            SnackBars.showSuccessSnackBar(
              context,
              'Successfully assigned ${driver.name} to Card #${widget.request.cardNumber}',
            );
            widget.onAssignmentComplete();
          } else if (state is AssignmentError) {
            SnackBars.showErrorSnackBar(
              context,
              'Failed to assign driver: ${state.message}',
            );
          }
        },
        child: AssignmentConfirmationDialog(
          driver: driver,
          request: widget.request,
          onConfirm: () {
            dashboardBloc.add(
              AssignDriverToRetrieval(
                driverUserId: driver.userId,
                sessionId: widget.request.sessionId,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<AvailableDriver>(
      onWillAcceptWithDetails: (details) {
        // Only accept if driver status is 'free'
        return details.data.status.toLowerCase() == 'free';
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _isDraggingOver = false;
        });
        _showAssignmentDialog(details.data);
      },
      onMove: (details) {
        if (!_isDraggingOver) {
          setState(() {
            _isDraggingOver = true;
          });
        }
      },
      onLeave: (data) {
        setState(() {
          _isDraggingOver = false;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.015,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.01,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: _isDraggingOver
                ? AppColors.primary.withOpacity(0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(
              color: _isDraggingOver
                  ? AppColors.primary
                  : RetrievalRequestUtils.getPriorityColor(
                      widget.request.waitingTime),
              width: _isDraggingOver ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isDraggingOver
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.grey.withOpacity(0.1),
                spreadRadius: _isDraggingOver ? 2 : 1,
                blurRadius: _isDraggingOver ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.request.vehicle.photo,
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.08,
                      height: MediaQuery.of(context).size.width * 0.08,
                      color: AppColors.grey.withOpacity(0.3),
                      child: Icon(
                        Icons.directions_car,
                        size: MediaQuery.of(context).size.width * 0.04,
                        color: AppColors.grey,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.012,
              ),
              // Information Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Card number and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextComponent(
                          labelText: '#${widget.request.cardNumber}',
                          fontSize: MediaQuery.of(context).size.width * 0.022,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.015,
                            vertical:
                                MediaQuery.of(context).size.height * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: RetrievalRequestUtils.getPriorityColor(
                                widget.request.waitingTime),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextComponent(
                            labelText: RetrievalRequestUtils.getPriorityLabel(
                                widget.request.waitingTime),
                            fontSize: MediaQuery.of(context).size.width * 0.014,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    // Row 2: Time and Requested at
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: MediaQuery.of(context).size.width * 0.016,
                              color: AppColors.error,
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.008),
                            TextComponent(
                              labelText: widget.request.waitingTime,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.016,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        TextComponent(
                          labelText:
                              'Requested at ${RetrievalRequestUtils.formatTime(widget.request.requestedAt)}',
                          fontSize: MediaQuery.of(context).size.width * 0.014,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    // Row 3: Requested by name and Phone number
                    Row(
                      children: [
                        TextComponent(
                          labelText: TextConstants.parkedBy,
                          fontSize: MediaQuery.of(context).size.width * 0.014,
                          color: AppColors.grey,
                        ),
                        TextComponent(
                          labelText: widget.request.parkedBy.name,
                          fontSize: MediaQuery.of(context).size.width * 0.016,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        Spacer(),
                        Icon(
                          Icons.phone_outlined,
                          size: MediaQuery.of(context).size.width * 0.016,
                          color: AppColors.grey,
                        ),
                        TextComponent(
                          labelText: widget.request.parkedBy.phone!,
                          fontSize: MediaQuery.of(context).size.width * 0.015,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
