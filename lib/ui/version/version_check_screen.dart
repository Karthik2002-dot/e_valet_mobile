import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:niloufer_valet_mobile/services/version/version_service.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/version/mandatory_update_dialog.dart';
import 'package:niloufer_valet_mobile/ui/version/version_check_args.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/operator_dashboard.dart';
import 'package:niloufer_valet_mobile/ui/permissions/permissions_screen.dart';
import 'package:niloufer_valet_mobile/services/permissions/permissions_service.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';

/// Wrapper that shows the destination screen and runs version check as a popup
/// (dialog) on top. No dedicated version-check screen — only a small dialog.
class VersionCheckScreen extends StatefulWidget {
  final VersionCheckArgs args;

  const VersionCheckScreen({super.key, required this.args});

  @override
  State<VersionCheckScreen> createState() => _VersionCheckScreenState();
}

class _VersionCheckScreenState extends State<VersionCheckScreen> {
  bool _loadingDialogDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _runVersionCheckPopup());
  }

  Widget _buildDestination() {
    final args = widget.args;
    if (args.isAuthenticated) {
      final isOperator = args.roles.any((r) => r.contains('operator'));
      final isDriver = args.roles.any((r) => r.contains('driver'));
      if (isOperator) return const OperatorDashboardScreen();
      if (isDriver) return const DriverHomeScreen();
      return const LoginScreen();
    }
    return const LoginScreen();
  }

  Future<void> _runVersionCheckPopup() async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextComponent(
                  labelText: TextConstants.checkingForUpdates,
                  fontSize: 16,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = packageInfo.version;
      final remoteBuildNumber = await VersionService.getRemoteBuildNumber();

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss "Checking for updates..." dialog
      _loadingDialogDismissed = true;

      if (remoteBuildNumber != null &&
          VersionService.isLocalVersionLowerThan(
              localVersion, remoteBuildNumber)) {
        await MandatoryUpdateDialog.show(context);
        return;
      }

      if (!mounted) return;

      final allPermissionsGranted = await PermissionsService.areAllGranted();
      if (!mounted) return;
      if (allPermissionsGranted) {
        PermissionsService.setPermissionsCompletedOnce();
        _navigateToDestination(context, widget.args);
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PermissionsScreen(args: widget.args),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      if (!_loadingDialogDismissed) {
        Navigator.of(context).pop();
      }
      final allGranted = await PermissionsService.areAllGranted();
      if (!mounted) return;
      if (allGranted) {
        PermissionsService.setPermissionsCompletedOnce();
        _navigateToDestination(context, widget.args);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PermissionsScreen(args: widget.args),
          ),
        );
      }
    }
  }

  void _navigateToDestination(BuildContext context, VersionCheckArgs args) {
    if (args.isAuthenticated) {
      final isOperator = args.roles.any((r) => r.contains('operator'));
      final isDriver = args.roles.any((r) => r.contains('driver'));
      if (isOperator) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const OperatorDashboardScreen(),
          ),
        );
        return;
      }
      if (isDriver) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
        );
        return;
      }
      SnackBars.showErrorSnackBar(
        context,
        'Your account does not have the required permissions to access this app.',
      );
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) => _buildDestination();
}
