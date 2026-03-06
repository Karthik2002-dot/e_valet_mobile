import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_state.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_overtime/operator_overtime_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_overtime/operator_overtime_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_overtime/operator_overtime_state.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_valet/valet_response.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/guidelines/guidelines_screen.dart';
import 'package:niloufer_valet_mobile/ui/help_support/help_screen.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/profile_screen.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/operator_dashboard.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drawer/operator_drawer.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_overtime/overtime_confirm_dialog.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_overtime/overtime_valet_row.dart';

/// Over Time screen for the valet operator.
/// Shows the same valet list data as the valet dashboard: name, phone, and status (Available / On Duty / On Break / Offline).
class OperatorOverTimeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const OperatorOverTimeScreen({super.key, this.onNavigateToTab});

  @override
  State<OperatorOverTimeScreen> createState() => _OperatorOverTimeScreenState();
}

class _OperatorOverTimeScreenState extends State<OperatorOverTimeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final OperatorMenuBloc _menuBloc;
  late final OperatorOvertimeBloc _overtimeBloc;
  final String _outletId = dotenv.env['OUTLET_ID'] ?? '1';
  final Map<String, String> _overtimeInputs = {};

  @override
  void initState() {
    super.initState();
    _menuBloc = OperatorMenuBloc();
    _overtimeBloc = OperatorOvertimeBloc()
      ..add(OvertimeLoadValets(outletId: _outletId));
  }

  void _goToDashboard() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab?.call(0);
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OperatorDashboardScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _menuBloc.close();
    _overtimeBloc.close();
    super.dispose();
  }

  void _onMenuItemSelected(int index) {
    if (index == 8) {
      _menuBloc.add(const OperatorMenuLogoutRequested());
      return;
    }

    if (index == 4) {
      // Already on Over Time
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

    if (index >= 0 && index <= 3) {
      // Switch operator dashboard tab
      if (widget.onNavigateToTab != null) {
        Navigator.of(context).pop();
        widget.onNavigateToTab?.call(index);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OperatorDashboardScreen()),
          (route) => false,
        );
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _menuBloc),
        BlocProvider.value(value: _overtimeBloc),
      ],
      child: BlocListener<OperatorMenuBloc, OperatorMenuState>(
        listener: (context, state) {
          if (state is OperatorMenuLogoutSuccess) {
            SnackBars.showSuccessSnackBar(context, state.message);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          } else if (state is OperatorMenuLogoutFailure) {
            SnackBars.showErrorSnackBar(context, state.message);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: BlocListener<OperatorOvertimeBloc, OperatorOvertimeState>(
          listenWhen: (previous, current) =>
              current is OperatorOvertimeGrantSuccess ||
              current is OperatorOvertimeGrantError,
          listener: (context, state) {
            if (state is OperatorOvertimeGrantSuccess) {
              SnackBars.showSuccessSnackBar(context, state.message);
              setState(() => _overtimeInputs[state.driverUserId] = '');
            } else if (state is OperatorOvertimeGrantError) {
              SnackBars.showErrorSnackBar(context, state.message);
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.white,
            endDrawer: OperatorDrawer(
              selectedIndex: 4,
              onItemSelected: _onMenuItemSelected,
            ),
            appBar: CustomAppBar(
              showLanguageIcon: true,
              actions: [
                IconButton(
                  onPressed: () => _overtimeBloc.add(
                    OvertimeLoadValets(outletId: _outletId),
                  ),
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
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(width * 0.02),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button below common header (same as Parked Car)
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextComponent(
                                    labelText: t.get(TextConstants.overTime),
                                    color: AppColors.black,
                                    fontSize: headerTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 4),
                                  TextComponent(
                                    labelText: t
                                        .get(TextConstants.overtimeDescription),
                                    color: AppColors.grey,
                                    fontSize: headerDescriptionFontSize,
                                  ),
                                ],
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: TextComponent(
                              labelText: t.get(TextConstants.overtimeNote),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                              maxLines: 3,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<OperatorOvertimeBloc,
                              OperatorOvertimeState>(
                            builder: (context, overtimeState) {
                              if (overtimeState is OperatorOvertimeLoading) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (overtimeState is OperatorOvertimeLoadError) {
                                return Center(
                                  child: Column(
                                    children: [
                                      TextComponent(
                                        labelText:
                                            '${t.get(TextConstants.errorLabel)}: ${overtimeState.message}',
                                        color: AppColors.error,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () => _overtimeBloc.add(
                                          OvertimeLoadValets(
                                              outletId: _outletId),
                                        ),
                                        child: TextComponent(
                                          labelText:
                                              t.get(TextConstants.retryButton),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              if (overtimeState is! OperatorOvertimeLoaded) {
                                return const SizedBox.shrink();
                              }
                              final valets = overtimeState.valets;
                              if (valets.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: TextComponent(
                                      labelText: t.get(TextConstants
                                          .overtimeNoAvailableDrivers),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.grey,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                    ),
                                  ),
                                );
                              }
                              return Builder(
                                builder: (context) {
                                  const crossAxisSpacing = 12.0;
                                  const mainAxisSpacing = 12.0;
                                  // Keep single column on phones; show 2 columns on wider screens.
                                  final useTwoColumns = width >= 600;

                                  Widget buildRowForValet(ValetResponse valet) {
                                    return OvertimeValetRow(
                                      name: valet.name,
                                      phone: valet.phone,
                                      status: valet.status,
                                      value:
                                          _overtimeInputs[valet.userId] ?? '',
                                      onChanged: (v) => setState(
                                        () => _overtimeInputs[valet.userId] = v,
                                      ),
                                      onSubmit: () {
                                        final input =
                                            _overtimeInputs[valet.userId] ?? '';
                                        if (input.trim().isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: TextComponent(
                                                labelText: t.get(
                                                  TextConstants
                                                      .overtimeEnterNumbers,
                                                ),
                                                color: AppColors.white,
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        final minutes =
                                            int.tryParse(input.trim()) ?? 0;
                                        if (minutes <= 0) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: TextComponent(
                                                labelText: t.get(
                                                  TextConstants
                                                      .overtimeEnterNumbers,
                                                ),
                                                color: AppColors.white,
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        OvertimeConfirmDialog.show(
                                          context,
                                          driverUserId: valet.userId,
                                          extraMinutes: minutes,
                                          valetName: valet.name,
                                          onConfirm: () => context
                                              .read<OperatorOvertimeBloc>()
                                              .add(
                                                OvertimeGrantRequested(
                                                  driverUserId: valet.userId,
                                                  outletId:
                                                      int.tryParse(_outletId) ??
                                                          0,
                                                  extraMinutes: minutes,
                                                ),
                                              ),
                                        );
                                      },
                                    );
                                  }

                                  if (!useTwoColumns) {
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: valets.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(
                                              height: mainAxisSpacing),
                                      itemBuilder: (context, index) {
                                        return buildRowForValet(valets[index]);
                                      },
                                    );
                                  }

                                  // Two columns without IntrinsicHeight (avoids layout issues with TextField).
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      final itemWidth = ((constraints.maxWidth -
                                                  crossAxisSpacing) /
                                              2)
                                          // Cap card width to avoid huge empty space on tablets.
                                          .clamp(240.0, 380.0);
                                      return Wrap(
                                        spacing: crossAxisSpacing,
                                        runSpacing: mainAxisSpacing,
                                        children: [
                                          for (final v in valets)
                                            SizedBox(
                                              width: itemWidth,
                                              child: buildRowForValet(v),
                                            ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
