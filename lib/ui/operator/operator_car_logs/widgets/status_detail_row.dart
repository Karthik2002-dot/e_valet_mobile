import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class StatusDetailRow extends StatelessWidget {
  final String label;
  final String selectedStatus;
  final List<String> statusOptions;
  final Function(String) onStatusChanged;

  const StatusDetailRow({
    super.key,
    required this.label,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            value: selectedStatus,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              border: InputBorder.none,
            ),
            items: statusOptions.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onStatusChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
