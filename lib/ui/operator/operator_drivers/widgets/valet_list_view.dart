import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_valet/operator_valets/valet_list_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drivers/widgets/valet_card.dart';

class ValetListView extends StatelessWidget {
  final String outletId;
  final String searchQuery;

  const ValetListView({
    super.key,
    required this.outletId,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValetListBloc, ValetListState>(
      builder: (context, state) {
        if (state is ValetListLoading) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
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
          // Filter valets by searchQuery (name, phone, or userId)
          final query = searchQuery.trim().toLowerCase();
          List filteredValets;
          if (query.isEmpty) {
            filteredValets = state.response.valets;
          } else if (RegExp(r'^\d+$').hasMatch(query)) {
            // If query is all digits, match userId exactly
            filteredValets = state.response.valets.where((valet) => valet.userId.toLowerCase() == query).toList();
          } else {
            filteredValets = state.response.valets.where((valet) {
              return valet.name.toLowerCase().contains(query) ||
                     valet.phone.toLowerCase().contains(query) ||
                     valet.userId.toLowerCase().contains(query);
            }).toList();
          }

          if (filteredValets.isEmpty) {
            return Center(
              child: TextComponent(
                labelText: TextConstants.noValetsFound,
                color: AppColors.grey,
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
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
