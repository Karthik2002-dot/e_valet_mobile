import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_valet/valet_list_api_service.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_grouping/operator_driver_groups_api_service.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_grouping/add_group_member_request.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_grouping/driver_group.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_grouping/driver_group_member.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_valet/valet_response.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/guidelines/guidelines_screen.dart';
import 'package:niloufer_valet_mobile/ui/help_support/help_screen.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/profile_screen.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drawer/operator_drawer.dart';
import 'package:provider/provider.dart';

class OperatorGroupingScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const OperatorGroupingScreen({super.key, this.onNavigateToTab});

  @override
  State<OperatorGroupingScreen> createState() => _OperatorGroupingScreenState();
}

class _OperatorGroupingScreenState extends State<OperatorGroupingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _outletId = dotenv.env['OUTLET_ID'] ?? '1';
  Future<List<DriverGroup>>? _groupsFuture;
  final Map<int, Future<List<DriverGroupMember>>> _membersFuturesByGroupId = {};
  Future<List<ValetResponse>>? _valetsFuture;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      _groupsFuture = OperatorDriverGroupsApiService.getDriverGroups(
        outletId: _outletId,
      ).then((res) => res.groups);
      _membersFuturesByGroupId.clear();
      _valetsFuture = null;
    });
  }

  void _loadValetsIfNeeded() {
    _valetsFuture ??= ValetListApiService.getValets(outletId: _outletId)
        .then((res) => res.valets);
  }

  Future<void> _showAddMembersDialog({
    required int groupId,
    required String groupName,
  }) async {
    final t = context.read<AppTranslationsNotifier>();
    _loadValetsIfNeeded();

    final selectedValets = <ValetResponse>[];
    bool isSubmitting = false;
    String? errorText;

    Future<void> submit(StateSetter setLocalState) async {
      if (selectedValets.isEmpty) {
        setLocalState(() {
          errorText = t.getByKey(
            'groupMembersRequired',
            'Please select at least one member',
          );
        });
        return;
      }

      setLocalState(() {
        errorText = null;
        isSubmitting = true;
      });

      try {
        for (final v in selectedValets) {
          await OperatorDriverGroupsApiService.addDriverGroupMember(
            outletId: _outletId,
            groupId: groupId,
            request: AddGroupMemberRequest(driverUserId: v.userId),
          );
        }

        if (!mounted) return;
        Navigator.of(context).pop();

        // Refresh only this group's members
        setState(() {
          _membersFuturesByGroupId[groupId] =
              OperatorDriverGroupsApiService.getDriverGroupMembers(
            outletId: _outletId,
            groupId: groupId,
          ).then((res) => res.members);
        });
      } catch (e) {
        setLocalState(() {
          errorText = e.toString();
          isSubmitting = false;
        });
      }
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            return Dialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (MediaQuery.of(context).size.width * 0.9)
                      .clamp(280.0, 420.0),
                  maxHeight: (MediaQuery.of(context).size.height * 0.55)
                      .clamp(220.0, 420.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextComponent(
                              labelText:
                                  '${t.getByKey('addMembers', 'Add Members')} - $groupName',
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              fontSize: 16,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            icon:
                                const Icon(Icons.close, color: AppColors.black),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextComponent(
                              labelText: t.getByKey(
                                'groupMembers',
                                'Group Members',
                              ),
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<List<ValetResponse>>(
                              future: _valetsFuture,
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (snap.hasError) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextComponent(
                                        labelText: t.getByKey(
                                          'valetsLoadFailed',
                                          'Failed to load valets',
                                        ),
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: isSubmitting
                                            ? null
                                            : () {
                                                setState(() {
                                                  _valetsFuture =
                                                      ValetListApiService
                                                          .getValets(
                                                    outletId: _outletId,
                                                  ).then((r) => r.valets);
                                                });
                                                setLocalState(() {});
                                              },
                                        child: TextComponent(
                                          labelText:
                                              t.getByKey('retry', 'Retry'),
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                final allValets = snap.data ?? [];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      readOnly: true,
                                      enabled: !isSubmitting,
                                      decoration: InputDecoration(
                                        hintText: t.getByKey(
                                          'selectMembers',
                                          'Select members',
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.people,
                                          color: AppColors.primary,
                                        ),
                                        suffixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: AppColors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onTap: () async {
                                        final picked =
                                            await showModalBottomSheet<
                                                List<ValetResponse>>(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: AppColors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                          ),
                                          builder: (sheetContext) {
                                            final searchController =
                                                TextEditingController();
                                            var filtered = allValets;
                                            final localSelectedIds = <String>{
                                              for (final v in selectedValets)
                                                v.userId
                                            };

                                            void applyFilter(
                                                StateSetter setSheet) {
                                              final q = searchController.text
                                                  .trim()
                                                  .toLowerCase();
                                              setSheet(() {
                                                if (q.isEmpty) {
                                                  filtered = allValets;
                                                } else {
                                                  filtered =
                                                      allValets.where((v) {
                                                    return v.name
                                                            .toLowerCase()
                                                            .contains(q) ||
                                                        v.phone
                                                            .toLowerCase()
                                                            .contains(q);
                                                  }).toList();
                                                }
                                              });
                                            }

                                            return StatefulBuilder(
                                              builder:
                                                  (sheetContext, setSheet) {
                                                return SafeArea(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom: MediaQuery.of(
                                                              sheetContext)
                                                          .viewInsets
                                                          .bottom,
                                                    ),
                                                    child: SizedBox(
                                                      height: (MediaQuery.of(
                                                                      sheetContext)
                                                                  .size
                                                                  .height *
                                                              0.75)
                                                          .clamp(300.0, 650.0),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    16,
                                                                    12,
                                                                    8,
                                                                    8),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      TextComponent(
                                                                    labelText: t
                                                                        .getByKey(
                                                                      'selectMembers',
                                                                      'Select members',
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: AppColors
                                                                        .black,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              sheetContext)
                                                                          .pop(),
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .close),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    16,
                                                                    0,
                                                                    16,
                                                                    12),
                                                            child: TextField(
                                                              controller:
                                                                  searchController,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    t.getByKey(
                                                                  'searchValets',
                                                                  'Search valets...',
                                                                ),
                                                                prefixIcon:
                                                                    const Icon(Icons
                                                                        .search),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                              ),
                                                              onChanged: (_) =>
                                                                  applyFilter(
                                                                      setSheet),
                                                            ),
                                                          ),
                                                          const Divider(
                                                              height: 1),
                                                          Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  filtered
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      idx) {
                                                                final v =
                                                                    filtered[
                                                                        idx];
                                                                final selected =
                                                                    localSelectedIds
                                                                        .contains(
                                                                            v.userId);
                                                                return CheckboxListTile(
                                                                  value:
                                                                      selected,
                                                                  onChanged:
                                                                      (checked) {
                                                                    setSheet(
                                                                        () {
                                                                      if (checked ==
                                                                          true) {
                                                                        localSelectedIds
                                                                            .add(v.userId);
                                                                      } else {
                                                                        localSelectedIds
                                                                            .remove(v.userId);
                                                                      }
                                                                    });
                                                                  },
                                                                  title:
                                                                      TextComponent(
                                                                    labelText:
                                                                        v.name,
                                                                    color: AppColors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  subtitle:
                                                                      TextComponent(
                                                                    labelText:
                                                                        v.phone,
                                                                    color:
                                                                        AppColors
                                                                            .grey,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                  controlAffinity:
                                                                      ListTileControlAffinity
                                                                          .leading,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          const Divider(
                                                              height: 1),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    16,
                                                                    10,
                                                                    16,
                                                                    16),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      OutlinedButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(sheetContext)
                                                                            .pop(),
                                                                    child:
                                                                        TextComponent(
                                                                      labelText:
                                                                          t.getByKey(
                                                                        'cancel',
                                                                        'Cancel',
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: AppColors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                Expanded(
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .primary,
                                                                      foregroundColor:
                                                                          AppColors
                                                                              .white,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      final picked = allValets
                                                                          .where((v) =>
                                                                              localSelectedIds.contains(v.userId))
                                                                          .toList();
                                                                      Navigator.of(
                                                                              sheetContext)
                                                                          .pop(
                                                                              picked);
                                                                    },
                                                                    child:
                                                                        TextComponent(
                                                                      labelText:
                                                                          t.getByKey(
                                                                        'done',
                                                                        'Done',
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: AppColors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );

                                        if (picked == null) return;
                                        setLocalState(() {
                                          selectedValets
                                            ..clear()
                                            ..addAll(picked);
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final v in selectedValets)
                                          Chip(
                                            label: TextComponent(
                                              labelText: v.name,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black,
                                            ),
                                            deleteIcon: const Icon(
                                              Icons.close,
                                              size: 18,
                                            ),
                                            onDeleted: isSubmitting
                                                ? null
                                                : () {
                                                    setLocalState(() {
                                                      selectedValets
                                                          .removeWhere((x) =>
                                                              x.userId ==
                                                              v.userId);
                                                    });
                                                  },
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            if (errorText != null) ...[
                              const SizedBox(height: 12),
                              TextComponent(
                                labelText: errorText!,
                                color: AppColors.error,
                                fontSize: 12,
                                maxLines: 4,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.of(dialogContext).pop(),
                              child: TextComponent(
                                labelText: t.getByKey('cancel', 'Cancel'),
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => submit(setLocalState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : TextComponent(
                                      labelText: t.getByKey('submit', 'Submit'),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddGroupDialog() async {
    final t = context.read<AppTranslationsNotifier>();
    _loadValetsIfNeeded();

    final nameController = TextEditingController();
    final selectedValets = <ValetResponse>[];
    bool isSubmitting = false;
    String? errorText;

    Future<void> submit(StateSetter setLocalState) async {
      final groupName = nameController.text.trim();
      if (groupName.isEmpty) {
        setLocalState(() {
          errorText = t.getByKey(
            'groupNameRequired',
            'Please enter group name',
          );
        });
        return;
      }
      if (selectedValets.isEmpty) {
        setLocalState(() {
          errorText = t.getByKey(
            'groupMembersRequired',
            'Please select at least one member',
          );
        });
        return;
      }

      setLocalState(() {
        errorText = null;
        isSubmitting = true;
      });

      try {
        final created = await OperatorDriverGroupsApiService.createDriverGroup(
          outletId: _outletId,
          name: groupName,
        );

        for (final v in selectedValets) {
          await OperatorDriverGroupsApiService.addDriverGroupMember(
            outletId: _outletId,
            groupId: created.id,
            request: AddGroupMemberRequest(driverUserId: v.userId),
          );
        }

        if (!mounted) return;
        Navigator.of(context).pop();
        _loadGroups(); // refresh UI + trigger GETs again
      } catch (e) {
        setLocalState(() {
          errorText = e.toString();
          isSubmitting = false;
        });
      }
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            return Dialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (MediaQuery.of(context).size.width * 0.9)
                      .clamp(280.0, 420.0),
                  maxHeight: (MediaQuery.of(context).size.height * 0.62)
                      .clamp(260.0, 460.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextComponent(
                              labelText: t.getByKey('addGroup', 'Add Group'),
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            icon:
                                const Icon(Icons.close, color: AppColors.black),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextComponent(
                              labelText: t.getByKey(
                                'groupName',
                                'Group Name',
                              ),
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nameController,
                              enabled: !isSubmitting,
                              decoration: InputDecoration(
                                hintText: t.getByKey(
                                  'enterGroupName',
                                  'Enter group name',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextComponent(
                              labelText: t.getByKey(
                                'groupMembers',
                                'Group Members',
                              ),
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<List<ValetResponse>>(
                              future: _valetsFuture,
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (snap.hasError) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextComponent(
                                        labelText: t.getByKey(
                                          'valetsLoadFailed',
                                          'Failed to load valets',
                                        ),
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: isSubmitting
                                            ? null
                                            : () {
                                                setState(() {
                                                  _valetsFuture =
                                                      ValetListApiService
                                                          .getValets(
                                                    outletId: _outletId,
                                                  ).then((r) => r.valets);
                                                });
                                                setLocalState(() {});
                                              },
                                        child: TextComponent(
                                          labelText:
                                              t.getByKey('retry', 'Retry'),
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                final allValets = snap.data ?? [];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      readOnly: true,
                                      enabled: !isSubmitting,
                                      decoration: InputDecoration(
                                        hintText: t.getByKey(
                                          'selectMembers',
                                          'Select members',
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.people,
                                          color: AppColors.primary,
                                        ),
                                        suffixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: AppColors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onTap: () async {
                                        final picked =
                                            await showModalBottomSheet<
                                                List<ValetResponse>>(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: AppColors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                          ),
                                          builder: (sheetContext) {
                                            final searchController =
                                                TextEditingController();
                                            var filtered = allValets;
                                            final localSelectedIds = <String>{
                                              for (final v in selectedValets)
                                                v.userId
                                            };

                                            void applyFilter(
                                                StateSetter setSheet) {
                                              final q = searchController.text
                                                  .trim()
                                                  .toLowerCase();
                                              setSheet(() {
                                                if (q.isEmpty) {
                                                  filtered = allValets;
                                                } else {
                                                  filtered =
                                                      allValets.where((v) {
                                                    return v.name
                                                            .toLowerCase()
                                                            .contains(q) ||
                                                        v.phone
                                                            .toLowerCase()
                                                            .contains(q);
                                                  }).toList();
                                                }
                                              });
                                            }

                                            return StatefulBuilder(
                                              builder:
                                                  (sheetContext, setSheet) {
                                                return SafeArea(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom: MediaQuery.of(
                                                              sheetContext)
                                                          .viewInsets
                                                          .bottom,
                                                    ),
                                                    child: SizedBox(
                                                      height: (MediaQuery.of(
                                                                      sheetContext)
                                                                  .size
                                                                  .height *
                                                              0.75)
                                                          .clamp(300.0, 650.0),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    16,
                                                                    12,
                                                                    8,
                                                                    8),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      TextComponent(
                                                                    labelText: t
                                                                        .getByKey(
                                                                      'selectMembers',
                                                                      'Select members',
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: AppColors
                                                                        .black,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              sheetContext)
                                                                          .pop(),
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .close),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    16,
                                                                    0,
                                                                    16,
                                                                    12),
                                                            child: TextField(
                                                              controller:
                                                                  searchController,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    t.getByKey(
                                                                  'searchValets',
                                                                  'Search valets...',
                                                                ),
                                                                prefixIcon:
                                                                    const Icon(Icons
                                                                        .search),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                              ),
                                                              onChanged: (_) =>
                                                                  applyFilter(
                                                                      setSheet),
                                                            ),
                                                          ),
                                                          const Divider(
                                                              height: 1),
                                                          Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  filtered
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      idx) {
                                                                final v =
                                                                    filtered[
                                                                        idx];
                                                                final selected =
                                                                    localSelectedIds
                                                                        .contains(
                                                                            v.userId);
                                                                return CheckboxListTile(
                                                                  value:
                                                                      selected,
                                                                  onChanged:
                                                                      (checked) {
                                                                    setSheet(
                                                                        () {
                                                                      if (checked ==
                                                                          true) {
                                                                        localSelectedIds
                                                                            .add(v.userId);
                                                                      } else {
                                                                        localSelectedIds
                                                                            .remove(v.userId);
                                                                      }
                                                                    });
                                                                  },
                                                                  title:
                                                                      TextComponent(
                                                                    labelText:
                                                                        v.name,
                                                                    color: AppColors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  subtitle:
                                                                      TextComponent(
                                                                    labelText:
                                                                        v.phone,
                                                                    color:
                                                                        AppColors
                                                                            .grey,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                  controlAffinity:
                                                                      ListTileControlAffinity
                                                                          .leading,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          const Divider(
                                                              height: 1),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    16,
                                                                    10,
                                                                    16,
                                                                    16),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      OutlinedButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(sheetContext)
                                                                            .pop(),
                                                                    child:
                                                                        TextComponent(
                                                                      labelText:
                                                                          t.getByKey(
                                                                        'cancel',
                                                                        'Cancel',
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: AppColors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                Expanded(
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .primary,
                                                                      foregroundColor:
                                                                          AppColors
                                                                              .white,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      final picked = allValets
                                                                          .where((v) =>
                                                                              localSelectedIds.contains(v.userId))
                                                                          .toList();
                                                                      Navigator.of(
                                                                              sheetContext)
                                                                          .pop(
                                                                              picked);
                                                                    },
                                                                    child:
                                                                        TextComponent(
                                                                      labelText:
                                                                          t.getByKey(
                                                                        'done',
                                                                        'Done',
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: AppColors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );

                                        if (picked == null) return;
                                        setLocalState(() {
                                          selectedValets
                                            ..clear()
                                            ..addAll(picked);
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final v in selectedValets)
                                          Chip(
                                            label: TextComponent(
                                              labelText: v.name,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black,
                                            ),
                                            deleteIcon: const Icon(
                                              Icons.close,
                                              size: 18,
                                            ),
                                            onDeleted: isSubmitting
                                                ? null
                                                : () {
                                                    setLocalState(() {
                                                      selectedValets
                                                          .removeWhere((x) =>
                                                              x.userId ==
                                                              v.userId);
                                                    });
                                                  },
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            if (errorText != null) ...[
                              const SizedBox(height: 12),
                              TextComponent(
                                labelText: errorText!,
                                color: AppColors.error,
                                fontSize: 12,
                                maxLines: 4,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.of(dialogContext).pop(),
                              child: TextComponent(
                                labelText: t.getByKey('cancel', 'Cancel'),
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => submit(setLocalState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : TextComponent(
                                      labelText: t.getByKey('submit', 'Submit'),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _goToDashboard() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab?.call(0);
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop();
  }

  void _onMenuItemSelected(int index) {
    if (index == 9) {
      // Already on Grouping
      return;
    }

    if (index == 4) {
      // Over Time is a separate screen; keep current navigation behavior (open from dashboard).
      Navigator.of(context).pop();
      widget.onNavigateToTab?.call(0);
      return;
    }

    if (index == 5) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }

    if (index == 6) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const HelpScreen(isFromOperator: true)),
      );
      return;
    }

    if (index == 7) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const GuidelinesScreen(isOperatorGuidelines: true),
        ),
      );
      return;
    }

    if (index == 8) {
      // Logout is handled by dashboard/overtime screens where the bloc exists.
      Navigator.of(context).pop();
      return;
    }

    if (index >= 0 && index <= 3) {
      if (widget.onNavigateToTab != null) {
        Navigator.of(context).pop();
        widget.onNavigateToTab?.call(index);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    final width = MediaQuery.of(context).size.width;
    final isAndroidPhone = !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        width < 600;

    final headerTitleFontSize =
        isAndroidPhone ? (width * 0.05).clamp(18.0, 22.0) : (width * 0.03);
    final headerDescriptionFontSize =
        isAndroidPhone ? (width * 0.038).clamp(14.0, 16.0) : (width * 0.02);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      endDrawer: OperatorDrawer(
        selectedIndex: 9,
        onItemSelected: _onMenuItemSelected,
      ),
      appBar: CustomAppBar(
        showLanguageIcon: true,
        actions: [
          IconButton(
            onPressed: _loadGroups,
            icon: const Icon(Icons.refresh, color: AppColors.white),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.white),
            onPressed: () {
              final currentScope = FocusScope.of(context);
              if (!currentScope.hasPrimaryFocus &&
                  currentScope.focusedChild != null) {
                currentScope.unfocus();
              }
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.black,
                    onPressed: _goToDashboard,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextComponent(
                        labelText: t.getByKey('grouping', 'Grouping'),
                        color: AppColors.black,
                        fontSize: headerTitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      TextComponent(
                        labelText: t.getByKey(
                          'groupingDescription',
                          'Manage operator groupings',
                        ),
                        color: AppColors.grey,
                        fontSize: headerDescriptionFontSize,
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showAddGroupDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: (headerTitleFontSize * 1.2).clamp(22.0, 28.0),
                    ),
                    label: TextComponent(
                      labelText: t.getByKey('addGroup', 'Add Group'),
                      color: AppColors.primary,
                      fontSize: headerTitleFontSize,
                      fontWeight: FontWeight.bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<DriverGroup>>(
                future: _groupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextComponent(
                              labelText: t.getByKey(
                                'groupingLoadFailed',
                                'Failed to load groups',
                              ),
                              color: AppColors.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            TextComponent(
                              labelText: snapshot.error.toString(),
                              color: AppColors.grey,
                              fontSize: 12,
                              textAlign: TextAlign.center,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _loadGroups,
                              child: TextComponent(
                                labelText: t.getByKey('retry', 'Retry'),
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final groups = snapshot.data ?? [];
                  if (groups.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: TextComponent(
                          labelText: t.getByKey(
                            'groupingNoGroups',
                            'No groups found',
                          ),
                          color: AppColors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (final g in groups)
                        Container(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                      onPressed: () => _showAddMembersDialog(
                                        groupId: g.id,
                                        groupName: g.name,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      icon: const Icon(Icons.person_add_alt_1,
                                          size: 18),
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
                                  future: _membersFuturesByGroupId.putIfAbsent(
                                    g.id,
                                    () => OperatorDriverGroupsApiService
                                        .getDriverGroupMembers(
                                      outletId: _outletId,
                                      groupId: g.id,
                                    ).then((res) => res.members),
                                  ),
                                  builder: (context, membersSnap) {
                                    if (membersSnap.connectionState ==
                                        ConnectionState.waiting) {
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              labelText:
                                                  membersSnap.error.toString(),
                                              color: AppColors.grey,
                                              fontSize: 12,
                                              maxLines: 3,
                                            ),
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _membersFuturesByGroupId[
                                                            g.id] =
                                                        OperatorDriverGroupsApiService
                                                            .getDriverGroupMembers(
                                                      outletId: _outletId,
                                                      groupId: g.id,
                                                    ).then((res) =>
                                                            res.members);
                                                  });
                                                },
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withValues(alpha: 0.12),
                                                  child: TextComponent(
                                                    labelText: (m
                                                                .name.isNotEmpty
                                                            ? m.name.trim()[0]
                                                            : '?')
                                                        .toUpperCase(),
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextComponent(
                                                        labelText:
                                                            m.name.isEmpty
                                                                ? '—'
                                                                : m.name,
                                                        color: AppColors.black,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      TextComponent(
                                                        labelText: m.phone,
                                                        color: AppColors.grey,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      TextComponent(
                                                        labelText:
                                                            '${t.getByKey('joinedAt', 'Joined at')}: ${m.joinedAt}',
                                                        color: AppColors.grey,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
