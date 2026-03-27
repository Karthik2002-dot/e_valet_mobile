import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_grouping/driver_group.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_grouping/driver_group_member.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class GroupingGroupListCard extends StatelessWidget {
  const GroupingGroupListCard({
    super.key,
    required this.group,
    required this.t,
    required this.membersFuture,
    required this.onAddMembers,
    required this.onRetryMembers,
  });

  final DriverGroup group;
  final AppTranslationsNotifier t;
  final Future<List<DriverGroupMember>> membersFuture;
  final VoidCallback onAddMembers;
  final VoidCallback onRetryMembers;

  @override
  Widget build(BuildContext context) {
    final g = group;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextComponent(
                        labelText: g.name,
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      TextComponent(
                        labelText:
                            '${t.getByKey('members', 'Members')}: ${g.memberCount}',
                        color: AppColors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onAddMembers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: TextComponent(
                    labelText: t.getByKey(
                      'addMembers',
                      'Add members',
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              color: AppColors.grey.withValues(alpha: 0.2),
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<DriverGroupMember>>(
              future: membersFuture,
              builder: (context, membersSnap) {
                if (membersSnap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (membersSnap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextComponent(
                          labelText: t.getByKey(
                            'groupMembersLoadFailed',
                            'Failed to load group members',
                          ),
                          color: AppColors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 6),
                        TextComponent(
                          labelText: membersSnap.error.toString(),
                          color: AppColors.grey,
                          fontSize: 12,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: onRetryMembers,
                            child: TextComponent(
                              labelText: t.getByKey(
                                'retry',
                                'Retry',
                              ),
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final members = membersSnap.data ?? [];
                if (members.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextComponent(
                      labelText: t.getByKey(
                        'groupMembersEmpty',
                        'No members found',
                      ),
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final m in members)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.12),
                              child: TextComponent(
                                labelText:
                                    (m.name.isNotEmpty ? m.name.trim()[0] : '?')
                                        .toUpperCase(),
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextComponent(
                                    labelText: m.name.isEmpty ? '—' : m.name,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  TextComponent(
                                    labelText: m.phone,
                                    color: AppColors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  TextComponent(
                                    labelText:
                                        '${t.getByKey('joinedAt', 'Joined at')}: ${m.joinedAt}',
                                    color: AppColors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
