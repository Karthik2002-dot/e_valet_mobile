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
  final Function(int cardNumber, String sessionId)? onManualRequest;

  const SlotsContentView({
    super.key,
    required this.digitalKeyRack,
    this.onManualRequest,
  });

  @override
  State<SlotsContentView> createState() => _SlotsContentViewState();
}

class _SlotsContentViewState extends State<SlotsContentView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<KeyRackItem> _getFilteredAndSortedItems() {
    final items = widget.digitalKeyRack.keyRack;
    
    if (_searchQuery.isEmpty) {
      return items;
    }

    // Separate matching and non-matching items
    final matching = <KeyRackItem>[];
    final nonMatching = <KeyRackItem>[];

    for (final item in items) {
      if (item.cardNumber.toString().contains(_searchQuery)) {
        matching.add(item);
      } else {
        nonMatching.add(item);
      }
    }

    // Return matching items first, then non-matching
    return [...matching, ...nonMatching];
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
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
        // Header with title and search
        Row(
          children: [
            Expanded(
              child: TextComponent(
                labelText: 'Occupied Slots ($occupiedSlots)',
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.02,
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            // Search Field
            SizedBox(
              width: screenWidth * 0.25,
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by card number...',
                  hintStyle: TextStyle(
                    color: AppColors.grey,
                    fontSize: screenWidth * 0.012,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: screenWidth * 0.015,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppColors.grey,
                            size: screenWidth * 0.015,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                    vertical: screenHeight * 0.01,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.grey.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.grey.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: screenWidth * 0.012,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        // Occupied Slots Grid
        if (occupiedSlots > 0) ...[
          // Show search results info if searching
          if (_searchQuery.isNotEmpty) ...[
            TextComponent(
              labelText: 'Showing results for "$_searchQuery"',
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
              final isMatch = _searchQuery.isNotEmpty && 
                              item.cardNumber.toString().contains(_searchQuery);
              
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
