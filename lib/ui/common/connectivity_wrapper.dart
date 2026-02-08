import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

/// Wraps the app and shows a no-internet overlay when there is no connectivity.
/// When connection returns or user taps Retry, the overlay is removed.
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  static bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _updateFromConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (!mounted) return;
      setState(() => _isOffline = !_hasConnection(results));
    } catch (_) {
      if (mounted) setState(() => _isOffline = false);
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (!mounted) return;
    setState(() => _isOffline = !_hasConnection(results));
  }

  @override
  void initState() {
    super.initState();
    try {
      _subscription =
          Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
      Connectivity().checkConnectivity().then((results) {
        if (!mounted) return;
        setState(() => _isOffline = !_hasConnection(results));
      }).catchError((_) {
        if (mounted) setState(() => _isOffline = false);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Widget _buildNoInternetOverlay() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: AppColors.background,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    constraints: const BoxConstraints(maxWidth: 360),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow10,
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.mutedText.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: 56,
                            color: AppColors.mutedText,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          TextConstants.noInternetTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            letterSpacing: -0.3,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          TextConstants.noInternetSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.mutedText,
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _updateFromConnectivity,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              TextConstants.retryConnection,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        widget.child,
        if (_isOffline)
          Positioned.fill(
            child: _buildNoInternetOverlay(),
          ),
      ],
    );
  }
}
