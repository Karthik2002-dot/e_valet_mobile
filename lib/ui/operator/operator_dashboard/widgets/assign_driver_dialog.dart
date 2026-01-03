import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_assign_retrieval_api_service.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/assign_retrieval_request.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/available_drivers.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/utils/driver_utils.dart';

class AssignDriverDialog extends StatefulWidget {
  final String sessionId;
  final List<AvailableDriver> availableDrivers;
  final VoidCallback onAssignmentComplete;

  const AssignDriverDialog({
    super.key,
    required this.sessionId,
    required this.availableDrivers,
    required this.onAssignmentComplete,
  });

  @override
  State<AssignDriverDialog> createState() => _AssignDriverDialogState();
}

class _AssignDriverDialogState extends State<AssignDriverDialog> {
  final OperatorAssignRetrievalApiService _apiService =
      OperatorAssignRetrievalApiService();
  bool _isLoading = false;

  Future<void> _assignDriver(AvailableDriver driver) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = AssignRetrievalRequest(
        sessionId: widget.sessionId,
        driverUserId: driver.userId,
      );

      final response = await _apiService.assignRetrieval(request: request);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAssignmentComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign driver: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter only free drivers
    final freeDrivers = widget.availableDrivers
        .where((d) => d.status.toLowerCase() == 'free')
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextComponent(
                  labelText: 'Assign Driver',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                IconButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextComponent(
              labelText: 'Select a driver to assign this retrieval request',
              fontSize: 14,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            if (freeDrivers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: TextComponent(
                    labelText: 'No available drivers at the moment',
                    color: AppColors.grey,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: freeDrivers.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final driver = freeDrivers[index];
                    return ListTile(
                      enabled: !_isLoading,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: TextComponent(
                          labelText: DriverUtils.getInitials(driver.name),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      title: TextComponent(
                        labelText: driver.name,
                        fontWeight: FontWeight.w500,
                      ),
                      subtitle: TextComponent(
                        labelText: driver.phone,
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: DriverUtils.getStatusColor(driver.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextComponent(
                          labelText: driver.status,
                          fontSize: 12,
                          color: DriverUtils.getStatusColor(driver.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: _isLoading ? null : () => _assignDriver(driver),
                    );
                  },
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
