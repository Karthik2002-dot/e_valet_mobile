import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/widgets/valet_card.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/widgets/valet_details_dialog.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/operator_drivers_screen.dart';

class ValetListView extends StatelessWidget {
  final String outletId;
  final String searchQuery;
  final ValetFilter statusFilter;

  const ValetListView({
    super.key,
    required this.outletId,
    this.searchQuery = '',
    this.statusFilter = ValetFilter.all,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValetListBloc, ValetListState>(
      builder: (context, state) {
        if (state is ValetListLoading) {
          const mainAxisSpacing = 12.0;
          final width = MediaQuery.sizeOf(context).width;
          final useTwoColumns = width >= 360;
          if (!useTwoColumns) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(bottom: mainAxisSpacing),
                child: const ValetCard(isLoading: true),
              ),
            );
          }
          const crossAxisSpacing = 12.0;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, rowIndex) {
              return Padding(
                padding: EdgeInsets.only(bottom: mainAxisSpacing),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(child: ValetCard(isLoading: true)),
                      const SizedBox(width: crossAxisSpacing),
                      const Expanded(child: ValetCard(isLoading: true)),
                    ],
                  ),
                ),
              );
            },
          );
        }

        if (state is ValetListError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextComponent(
                  labelText: '${TextConstants.errorLabel}: ${state.message}',
                  color: AppColors.error,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ValetListBloc>().add(
                          FetchValetList(outletId: outletId),
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

        if (state is ValetListLoaded) {
          // First, filter by status based on selected KPI card
          List filteredValets = state.response.valets;

          // Apply status filter
          switch (statusFilter) {
            case ValetFilter.available:
              filteredValets = filteredValets
                  .where((valet) => valet.status.toLowerCase() == 'available')
                  .toList();
              break;
            case ValetFilter.onDuty:
              filteredValets = filteredValets
                  .where((valet) => valet.status.toLowerCase() == 'on_duty')
                  .toList();
              break;
            case ValetFilter.onBreak:
              filteredValets = filteredValets
                  .where((valet) => valet.status.toLowerCase() == 'on_break')
                  .toList();
              break;
            case ValetFilter.all:
              // Show all valets
              break;
          }

          // Then filter by searchQuery (name, phone, or userId)
          final query = searchQuery.trim().toLowerCase();
          if (query.isNotEmpty) {
            if (RegExp(r'^\d+$').hasMatch(query)) {
              // If query is all digits, match userId exactly
              filteredValets = filteredValets
                  .where((valet) => valet.userId.toLowerCase() == query)
                  .toList();
            } else {
              filteredValets = filteredValets.where((valet) {
                return valet.name.toLowerCase().contains(query) ||
                    valet.phone.toLowerCase().contains(query) ||
                    valet.userId.toLowerCase().contains(query);
              }).toList();
            }
          }

          if (filteredValets.isEmpty) {
            return Center(
              child: TextComponent(
                labelText: TextConstants.noValetsFound,
                color: AppColors.grey,
              ),
            );
          }

          // Responsive: single column on narrow (e.g. small iPhone), two columns on wider
          const crossAxisSpacing = 12.0;
          const mainAxisSpacing = 12.0;
          final width = MediaQuery.sizeOf(context).width;
          final useTwoColumns = width >= 360; // Single column below 360px to avoid overflow

          if (!useTwoColumns) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredValets.length,
              itemBuilder: (context, index) {
                final valet = filteredValets[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: mainAxisSpacing),
                  child: ValetCard(
                    valet: valet,
                    onTap: () => ValetDetailsDialog.show(context, valet),
                  ),
                );
              },
            );
          }

          // Two columns: cards side by side, row height = taller card
          final rowCount = (filteredValets.length + 1) ~/ 2;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowCount,
            itemBuilder: (context, rowIndex) {
              final leftIndex = rowIndex * 2;
              final rightIndex = rowIndex * 2 + 1;
              final leftValet =
                  leftIndex < filteredValets.length
                      ? filteredValets[leftIndex]
                      : null;
              final rightValet =
                  rightIndex < filteredValets.length
                      ? filteredValets[rightIndex]
                      : null;
              return Padding(
                padding: EdgeInsets.only(bottom: mainAxisSpacing),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ValetCard(
                          valet: leftValet,
                          onTap: () =>
                              ValetDetailsDialog.show(context, leftValet!),
                        ),
                      ),
                      const SizedBox(width: crossAxisSpacing),
                      Expanded(
                        child: rightValet != null
                            ? ValetCard(
                                valet: rightValet,
                                onTap: () => ValetDetailsDialog.show(
                                    context, rightValet!),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
