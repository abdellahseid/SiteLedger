import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/local/database.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state.dart';

class SyncCenterScreen extends ConsumerStatefulWidget {
  const SyncCenterScreen({super.key});

  @override
  ConsumerState<SyncCenterScreen> createState() => _SyncCenterScreenState();
}

class _SyncCenterScreenState extends ConsumerState<SyncCenterScreen> {
  bool _isSyncing = false;

  void _handleSyncAll() async {
    setState(() => _isSyncing = true);
    final syncManager = ref.read(syncManagerProvider);
    try {
      final res = await syncManager.syncAllPending();
      ref.invalidate(pendingSyncCountProvider);
      ref.invalidate(receiptsProvider);
      ref.invalidate(discrepanciesProvider);
      ref.invalidate(dashboardMetricsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: res.failedCount > 0 ? AppColors.amberWarning : AppColors.emeraldSuccess,
            content: Text(res.message),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncManager = ref.watch(syncManagerProvider);
    final pendingAsync = ref.watch(pendingSyncCountProvider);
    final pendingCount = pendingAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync Center'),
      ),
      body: FutureBuilder<List<SyncOutboxData>>(
        future: syncManager.getOutboxItems(),
        builder: (context, snapshot) {
          final outbox = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: [
              // Sync Status Overview Hero Card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.electricBlue.withOpacity(0.2)),
                  boxShadow: AppShadows.cardHover,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.electricBlue.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.storage_rounded, color: Color(0xFF38BDF8), size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Drift SQLite Engine',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: pendingCount > 0 ? AppColors.amberWarning.withOpacity(0.2) : AppColors.emeraldSuccess.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: pendingCount > 0 ? AppColors.amberWarning : AppColors.emeraldSuccess,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: pendingCount > 0 ? AppColors.amberWarning : AppColors.emeraldSuccess,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  pendingCount > 0 ? '$pendingCount Pending' : 'All Synced',
                                  style: TextStyle(
                                    color: pendingCount > 0 ? AppColors.amberWarning : AppColors.emeraldSuccess,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'SiteLedger stores delivery scans in an encrypted local SQLite outbox. When mobile data fluctuates on remote Ethiopian construction sites, records are preserved and automatically synchronized with the central cloud ledger.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Idempotency Handshake:', style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                            const Text('UUID v4 Guaranteed', style: TextStyle(fontSize: 11.5, color: Color(0xFF38BDF8), fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSyncing ? null : _handleSyncAll,
                        icon: _isSyncing
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.sync_rounded),
                        label: Text(
                          _isSyncing ? 'Synchronizing Outbox...' : 'Sync Outbox Now',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Outbox Queue Items',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                  ),
                  Text(
                    '${outbox.length} in database',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (outbox.isEmpty)
                const EmptyState(
                  icon: Icons.cloud_done_rounded,
                  title: 'Outbox is Clean & Synced',
                  message: 'All local construction deliveries have been verified and confirmed with the central cloud ledger.',
                )
              else
                ...outbox.map((item) {
                  final isFailed = item.syncStatus == 'FAILED';
                  final isCompleted = item.syncStatus == 'COMPLETED';

                  Color statusColor = AppColors.amberWarning;
                  if (isCompleted) statusColor = AppColors.emeraldSuccess;
                  if (isFailed) statusColor = AppColors.redCritical;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isCompleted ? Icons.check_circle_rounded : (isFailed ? Icons.error_rounded : Icons.pending_rounded),
                                    size: 18,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.actionType.replaceAll('_', ' '),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.navyDark),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.syncStatus,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Key: ${item.idempotencyKey.substring(0, 16)}...',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Queued: ${Formatters.dateTime(item.createdAt)}',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWarm,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Retries: ${item.retryCount}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.navyDark, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          if (item.errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.redBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Error: ${item.errorMessage}',
                                style: const TextStyle(fontSize: 11, color: AppColors.redCritical),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
