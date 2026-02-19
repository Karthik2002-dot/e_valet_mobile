import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/widgets/valet_card.dart';
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
          final isIOS = Platform.isIOS;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isIOS ? 2 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isIOS ? 1.25 : 1.8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return const ValetCard(
                isLoading: true,
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

          final isIOS = Platform.isIOS;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isIOS ? 1.25 : 2,
            ),
            itemCount: filteredValets.length,
            itemBuilder: (context, index) {
              return ValetCard(
                valet: filteredValets[index],
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
