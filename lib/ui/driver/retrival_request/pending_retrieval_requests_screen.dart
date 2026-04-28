import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/api/driver/sessions_pending_api.dart';
import 'package:niloufer_valet_mobile/models/driver/session/pending_session.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/full_image_viewer_dialog.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_screen.dart';
import 'package:niloufer_valet_mobile/utils/session_converter.dart';

class PendingRetrievalRequestsScreen extends StatefulWidget {
  const PendingRetrievalRequestsScreen({super.key});

  @override
  State<PendingRetrievalRequestsScreen> createState() =>
      _PendingRetrievalRequestsScreenState();
}

class _PendingRetrievalRequestsScreenState
    extends State<PendingRetrievalRequestsScreen> {
  late Future<List<PendingSession>> _pendingRetrievalsFuture;

  @override
  void initState() {
    super.initState();
    _pendingRetrievalsFuture = _loadPendingRetrievals();
  }

  Future<List<PendingSession>> _loadPendingRetrievals() async {
    final pendingResponse = await SessionsPendingApiService.getPendingSessions();
    return pendingResponse.sessions.where(_isRetrievalTask).toList();
  }

  bool _isRetrievalTask(PendingSession session) {
    final taskType = (session.taskType ?? '').trim().toUpperCase();
    if (taskType.contains('RETRIEVAL') || taskType.contains('RETRIEVE')) {
      return true;
    }
    return session.isAccepted || session.isArrived;
  }

  Future<void> _refresh() async {
    final next = _loadPendingRetrievals();
    setState(() {
      _pendingRetrievalsFuture = next;
    });
    await next;
  }

  String _statusLabel(PendingSession session) {
    final normalized = session.status.trim().toUpperCase();
    if (normalized == 'ACCEPT' || normalized == 'ACCEPTED') return 'Accepted';
    if (normalized == 'ARRIVED') return 'Arrived';
    return normalized.isEmpty ? 'Pending' : normalized;
  }

  Color _statusColor(PendingSession session) {
    final normalized = session.status.trim().toUpperCase();
    if (normalized == 'ARRIVED') return AppColors.primary;
    if (normalized == 'ACCEPT' || normalized == 'ACCEPTED') {
      return AppColors.success;
    }
    return AppColors.mutedText;
  }

  String? _photoUrl(PendingSession session) {
    if (session.photos.isEmpty) return null;
    final first = session.photos.first;
    if (first is String && first.trim().isNotEmpty) return first.trim();
    if (first is Map) {
      final map = Map<String, dynamic>.from(first);
      final candidates = [
        map['url'],
        map['photoUrl'],
        map['imageUrl'],
        map['secureUrl'],
      ];
      for (final value in candidates) {
        final url = value?.toString().trim() ?? '';
        if (url.isNotEmpty) return url;
      }
    }
    return null;
  }

  Future<void> _continueRetrievalFlow(PendingSession session) async {
    final assignedSession = SessionConverter.pendingToAssigned(session);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfirmArrivalScreen(
          session: assignedSession,
          preventBackNavigation: true,
          showHandoverOnLoad: session.isArrived,
        ),
      ),
    );
    if (!mounted) return;
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    return Scaffold(
      backgroundColor: AppColors.lightBeigeBackground,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        showOverflowMenu: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<PendingSession>>(
          future: _pendingRetrievalsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextComponent(
                        labelText: snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              );
            }

            final retrievals = snapshot.data ?? const <PendingSession>[];
            if (retrievals.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: TextComponent(
                      labelText: t.get(TextConstants.retrievalRequests),
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextComponent(
                        labelText:
                            t.get(TextConstants.noPendingRetrievalRequests),
                        textAlign: TextAlign.center,
                        color: AppColors.mutedText,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              itemBuilder: (context, index) {
                final session = retrievals[index];
                final photoUrl = _photoUrl(session);
                final isTopFifoItem = index == 0;
                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow10,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    GestureDetector(
                      onTap: (photoUrl != null && photoUrl.isNotEmpty)
                          ? () => FullImageViewerDialog.show(context, photoUrl)
                          : null,
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, _, __) => Container(
                                  color: AppColors.greyLight.withOpacity(0.35),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported,
                                      color: AppColors.mutedText),
                                ),
                              )
                            : Container(
                                color: AppColors.greyLight.withOpacity(0.35),
                                alignment: Alignment.center,
                                child: const Icon(Icons.directions_car_filled,
                                    color: AppColors.mutedText, size: 34),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextComponent(
                                  labelText:
                                      '${TextConstants.cardNumber} ${session.cardNumber}',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(session).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: TextComponent(
                                  labelText: _statusLabel(session),
                                  color: _statusColor(session),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextComponent(
                            labelText:
                                '${TextConstants.parkingLocationLabel}: ${session.parkingLocation?.trim().isNotEmpty == true ? session.parkingLocation : '-'}',
                            color: AppColors.black,
                          ),
                          const SizedBox(height: 6),
                          TextComponent(
                            labelText:
                                'Pending for: ${session.pendingForMinutes} min',
                            color: AppColors.mutedText,
                          ),
                          if (isTopFifoItem) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () => _continueRetrievalFlow(session),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: TextComponent(
                                  labelText: t.getByKey(
                                    'continueLabel',
                                    TextConstants.continueLabel,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ]),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: retrievals.length,
            );
          },
        ),
      ),
    );
  }
}
