import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_grouping/operator_driver_groups_api_service.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_valet/valet_list_api_service.dart';
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
import 'package:niloufer_valet_mobile/ui/operator/operator_grouping/widgets/grouping_add_group_dialog.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_grouping/widgets/grouping_add_members_dialog.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_grouping/widgets/grouping_group_list_card.dart';
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
        .then((r) => r.valets);
  }

  void _reloadValets() {
    setState(() {
      _valetsFuture = ValetListApiService.getValets(outletId: _outletId)
          .then((r) => r.valets);
    });
  }

  Future<void> _showAddMembersDialog({
    required int groupId,
    required String groupName,
  }) async {
    final t = context.read<AppTranslationsNotifier>();
    await GroupingAddMembersDialog.show(
      context: context,
      t: t,
      outletId: _outletId,
      groupId: groupId,
      groupName: groupName,
      valetsFutureGetter: () => _valetsFuture,
      ensureValetsLoaded: _loadValetsIfNeeded,
      reloadValets: _reloadValets,
      onMembersAdded: (gid) {
        setState(() {
          _membersFuturesByGroupId[gid] =
              OperatorDriverGroupsApiService.getDriverGroupMembers(
            outletId: _outletId,
            groupId: gid,
          ).then((res) => res.members);
        });
      },
    );
  }

  Future<void> _showAddGroupDialog() async {
    final t = context.read<AppTranslationsNotifier>();
    await GroupingAddGroupDialog.show(
      context: context,
      t: t,
      outletId: _outletId,
      valetsFutureGetter: () => _valetsFuture,
      ensureValetsLoaded: _loadValetsIfNeeded,
      reloadValets: _reloadValets,
      onGroupCreated: _loadGroups,
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
      return;
    }

    if (index == 4) {
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
                        GroupingGroupListCard(
                          group: g,
                          t: t,
                          membersFuture: _membersFuturesByGroupId.putIfAbsent(
                            g.id,
                            () => OperatorDriverGroupsApiService
                                .getDriverGroupMembers(
                              outletId: _outletId,
                              groupId: g.id,
                            ).then((res) => res.members),
                          ),
                          onAddMembers: () => _showAddMembersDialog(
                            groupId: g.id,
                            groupName: g.name,
                          ),
                          onRetryMembers: () {
                            setState(() {
                              _membersFuturesByGroupId[g.id] =
                                  OperatorDriverGroupsApiService
                                      .getDriverGroupMembers(
                                outletId: _outletId,
                                groupId: g.id,
                              ).then((res) => res.members);
                            });
                          },
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
