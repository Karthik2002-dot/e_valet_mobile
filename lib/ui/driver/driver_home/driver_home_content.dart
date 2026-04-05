import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_header_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_online_content.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_offline_content.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_break_content.dart';

class DriverHomeContent extends StatefulWidget {
  final String driverName;
  final bool isOnBreak;
  final bool isOnline;
  final VoidCallback? onBreakEnd;

  /// When this notifier's value changes, we reset so home (two cards) is shown.
  final ValueNotifier<int>? homeResetNotifier;

  const DriverHomeContent({
    super.key,
    required this.driverName,
    required this.isOnBreak,
    required this.isOnline,
    this.onBreakEnd,
    this.homeResetNotifier,
  });

  @override
  State<DriverHomeContent> createState() => _DriverHomeContentState();
}

class _DriverHomeContentState extends State<DriverHomeContent>
    with WidgetsBindingObserver {
  /// When this key changes, DriverOnlineContent is recreated so reopen always shows home (two cards).
  Key _onlineContentKey = UniqueKey();

  /// True when Park Vehicle was tapped and we're on the vehicle details (QR) screen.
  bool _showParkFlow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.homeResetNotifier?.addListener(_onHomeReset);
  }

  @override
  void dispose() {
    widget.homeResetNotifier?.removeListener(_onHomeReset);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onHomeReset() {
    if (mounted)
      setState(() {
        _onlineContentKey = UniqueKey();
        _showParkFlow = false;
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app is reopened (resumed), preserve current screen - user stays on QR/park flow
    // unless they press back or navigate back.
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    final logoSize = isDesktop
        ? screenWidth * 0.08
        : isTablet
            ? screenWidth * 0.12
            : screenWidth * 0.2;

    final iconSize = isDesktop
        ? screenWidth * 0.02
        : isTablet
            ? screenWidth * 0.035
            : screenWidth * 0.06;

    return PopScope(
      // When in park flow (QR/Tag screen), system back should return to home cards,
      // not close the app.
      canPop: !_showParkFlow,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showParkFlow && mounted) {
          setState(() => _showParkFlow = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBeigeBackground,
        // Use CustomAppBar with language icon and menu
        appBar: CustomAppBar(
          showLanguageIcon: true,
          logoSize: logoSize,
          iconSize: iconSize,
        ),
        body: Column(
          children: [
            // Header Content Section (status card) — back button on left when in park flow, break toggle on right
            DriverHeaderWidget(
              isOnline: widget.isOnline,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              isTablet: isTablet,
              isDesktop: isDesktop,
              showBackButton: _showParkFlow,
              onBackPressed: _showParkFlow
                  ? () => setState(() => _showParkFlow = false)
                  : null,
            ),
            // Main Content Section with SafeArea
            // Show break content when on break (whether online or offline); else online content or offline content.
            Expanded(
              child: SafeArea(
                top: false,
                child: Container(
                  color: AppColors.lightBeigeBackground,
                  child: widget.isOnBreak
                      ? SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                            child: DriverBreakContent(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              isTablet: isTablet,
                              isDesktop: isDesktop,
                              onBreakEnd: widget.onBreakEnd,
                            ),
                          ),
                        )
                      : widget.isOnline
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                              ),
                              child: DriverOnlineContent(
                                key: _onlineContentKey,
                                driverName: widget.driverName,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                isTablet: isTablet,
                                isDesktop: isDesktop,
                                showParkFlow: _showParkFlow,
                                onParkFlowChanged: (value) =>
                                    setState(() => _showParkFlow = value),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                ),
                                child: DriverOfflineContent(
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  isTablet: isTablet,
                                  isDesktop: isDesktop,
                                ),
                              ),
                            ),
                ),
              ),
            ),
            // Footer
            SafeArea(
              top: false,
              child: const Footer(),
            ),
          ],
        ),
      ),
    );
  }
}
