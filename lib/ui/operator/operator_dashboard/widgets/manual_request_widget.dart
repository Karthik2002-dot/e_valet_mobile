import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_manual_retrieval_api_service.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/manual_retrieval_request.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/elevated_button.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_field.dart';

class ManualRequestWidget extends StatefulWidget {
  final VoidCallback onRequestCreated;

  const ManualRequestWidget({
    super.key,
    required this.onRequestCreated,
  });

  @override
  State<ManualRequestWidget> createState() => _ManualRequestWidgetState();
}

class _ManualRequestWidgetState extends State<ManualRequestWidget> {
  final TextEditingController _cardNumberController = TextEditingController();
  final OperatorManualRetrievalApiService _apiService =
      OperatorManualRetrievalApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleManualRequest() async {
    final cardNumberText = _cardNumberController.text.trim();
    if (cardNumberText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a card number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cardNumber = int.tryParse(cardNumberText);
    if (cardNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid card number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = ManualRetrievalRequest(
        cardNumber: cardNumber,
      );

      final response = await _apiService.createManualRetrievalRequest(
        outletId:
            '2', // TODO: Replace with actual outletId from session/profile
        request: request,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the field after successful request
        _cardNumberController.clear();

        // Trigger parent refresh
        widget.onRequestCreated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.02,
        horizontal: MediaQuery.of(context).size.width * 0.01,
      ),
      child: Row(
        children: [
          // Rounded text field with card icon
          Expanded(
            child: TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Enter Card Number.',
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: const Color(0xFFE0E0E0),
                prefixIcon: const Icon(
                  Icons.credit_card,
                  color: Colors.black87,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              onFieldSubmitted: (_) => _handleManualRequest(),
            ),
          ),

          const SizedBox(width: 16),

          // Manual Request button
          ElevatedButtonComponent(
            onPressed: _isLoading ? () {} : _handleManualRequest,
            labelText: _isLoading ? 'PROCESSING...' : 'MANUAL REQUEST',
            fontColor: AppColors.black,
            fontSize: MediaQuery.of(context).size.width * 0.015,
            elevatedButtonBackgroundColor:
                _isLoading ? AppColors.grey : AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.03,
              vertical: MediaQuery.of(context).size.height * 0.015,
            ),
          ),
        ],
      ),
    );
  }
}
