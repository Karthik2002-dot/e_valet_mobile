import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/car_log.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_event.dart';
import 'package:niloufer_valet_mobile/utils/time_utils.dart';

class CarLogDetailsPopup extends StatefulWidget {
  final CarLog carLog;
  final Function onClose;

  const CarLogDetailsPopup({
    super.key,
    required this.carLog,
    required this.onClose,
  });

  @override
  State<CarLogDetailsPopup> createState() => _CarLogDetailsPopupState();
}

class _CarLogDetailsPopupState extends State<CarLogDetailsPopup> {
  late TextEditingController _statusController;
  String _selectedStatus = '';
  bool _isSubmitting = false;

  // Define available status options
  final List<String> _statusOptions = [
    'CHECKED_IN',
    'PARKED',
    'RETRIEVAL_REQUESTED',
    'ASSIGNED',
    'ACCEPTED',
    'ARRIVED',
    'REPARKING',
    'COMPLETED',
    'CANCELLED'
  ];

  @override
  void initState() {
    super.initState();
    _statusController =
        TextEditingController(text: widget.carLog.displayStatus);
    // Normalize the status to match our dropdown options
    _selectedStatus = _normalizeStatus(widget.carLog.displayStatus);
  }

  String _normalizeStatus(String status) {
    // Convert common status variations to our standardized format
    switch (status.toLowerCase()) {
      case 'checked_in':
      case 'checked in':
        return 'CHECKED_IN';
      case 'parked':
        return 'PARKED';
      case 'retrieval_requested':
      case 'retrieval requested':
        return 'RETRIEVAL_REQUESTED';
      case 'assigned':
        return 'ASSIGNED';
      case 'accepted':
        return 'ACCEPTED';
      case 'arrived':
        return 'ARRIVED';
      case 'reparking':
      case 're-parking':
        return 'REPARKING';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
      case 'canceled':
        return 'CANCELLED';
      default:
        // If status doesn't match any option, default to first option
        return _statusOptions.first;
    }
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_selectedStatus.isEmpty ||
        _selectedStatus == widget.carLog.displayStatus) {
      widget.onClose();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Add update event to bloc
      final bloc = context.read<CarLogsBloc>();
      bloc.add(UpdateCarLogStatus(
        sessionId: widget.carLog.sessionId,
        newStatus: _selectedStatus,
      ));

      widget.onClose();
    } catch (e) {
      // Show error if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenSize.width * 0.8,
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: screenSize.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  TextComponent(
                    labelText: 'Car Log Details',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => widget.onClose(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSimpleDetailRow(
                        'Tag Number', widget.carLog.tagNumber.toString()),
                    const SizedBox(height: 16),
                    _buildSimpleDetailRow(
                        'Parked By',
                        widget.carLog.parkedBy.phone != null &&
                                widget.carLog.parkedBy.phone!.isNotEmpty
                            ? '${widget.carLog.parkedBy.name} (${widget.carLog.parkedBy.phone})'
                            : widget.carLog.parkedBy.name),
                    const SizedBox(height: 16),
                    _buildStatusDetailRow('Car Status', _selectedStatus),
                  ],
                ),
              ),
            ),

            // Footer with buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => widget.onClose(),
                    child: TextComponent(
                      labelText: 'Cancel',
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : TextComponent(
                            labelText: 'Submit',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextComponent(
          labelText: label,
          color: AppColors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        TextComponent(
          labelText: value,
          color: AppColors.black,
          fontSize: 16,
        ),
      ],
    );
  }

  Widget _buildStatusDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextComponent(
          labelText: label,
          color: AppColors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        Container(
          width: 200,
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              border: InputBorder.none,
            ),
            items: _statusOptions.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value ?? '';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextComponent(
          labelText: label,
          color: AppColors.black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey.withOpacity(0.3)),
          ),
          child: TextComponent(
            labelText: value,
            color: AppColors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
