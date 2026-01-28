import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/digital_key_rack_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/key_rack_item.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_slots/widgets/parked_car_card.dart';

class SlotsContentView extends StatefulWidget {
  final DigitalKeyRackResponse digitalKeyRack;
  final String searchQuery;
  final Function(int cardNumber, String sessionId)? onManualRequest;

  const SlotsContentView({
    super.key,
    required this.digitalKeyRack,
    required this.searchQuery,
    this.onManualRequest,
  });

  @override
  State<SlotsContentView> createState() => _SlotsContentViewState();
}

class _SlotsContentViewState extends State<SlotsContentView> {
  List<KeyRackItem> _getFilteredAndSortedItems() {
    final items = widget.digitalKeyRack.keyRack;

    if (widget.searchQuery.isEmpty) {
      return items;
    }

    // Separate matching and non-matching items
    final matching = <KeyRackItem>[];
    final nonMatching = <KeyRackItem>[];

    for (final item in items) {
      if (item.cardNumber.toString().contains(widget.searchQuery)) {
        matching.add(item);
      } else {
        nonMatching.add(item);
      }
    }

    // Return matching items first, then non-matching
    return [...matching, ...nonMatching];
  }

  @override
  Widget build(BuildContext context) {
    final occupiedSlots = widget.digitalKeyRack.keyRack.length;
    final filteredItems = _getFilteredAndSortedItems();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Occupied Slots Grid
        if (occupiedSlots > 0) ...[
          // Show search results info if searching
          if (widget.searchQuery.isNotEmpty) ...[
            TextComponent(
              labelText: 'Showing results for "${widget.searchQuery}"',
              color: AppColors.grey,
              fontSize: screenWidth * 0.013,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: screenHeight * 0.015),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: screenWidth * 0.02,
              mainAxisSpacing: screenHeight * 0.02,
              childAspectRatio: 0.7,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final isMatch = widget.searchQuery.isNotEmpty &&
                  item.cardNumber.toString().contains(widget.searchQuery);

              return ParkedCarCard(
                item: item,
                onManualRequest: widget.onManualRequest,
                isHighlighted: isMatch,
              );
            },
          ),
        ] else ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Icon(
                  Icons.check_circle_outline,
                  size: MediaQuery.of(context).size.width * 0.06,
                  color: AppColors.grey,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextComponent(
                  labelText: TextConstants.noCarsParked,
                  fontSize: MediaQuery.of(context).size.width * 0.018,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
