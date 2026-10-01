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
            padding: const EdgeInsets.all(16),
            children: [
              // Sync Status Overview Card
              Card(
                color: AppColors.navyDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Drift SQLite Engine',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: pendingCount > 0 ? AppColors.amberWarning : AppColors.emeraldSuccess,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pendingCount > 0 ? '$pendingCount Pending' : 'All Synced',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'SiteLedger keeps an encrypted SQLite queue on device. When signal drops in remote Ethiopian construction corridors, records never get lost.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: _isSyncing ? null : _handleSyncAll,
                        icon: _isSyncing
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.sync_rounded),
                        label: Text(_isSyncing ? 'Synchronizing Outbox...' : 'Sync Outbox Now'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Outbox Queue Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyDark),
              ),
              const SizedBox(height: 10),

              if (outbox.isEmpty)
                const EmptyState(
                  icon: Icons.cloud_done_outlined,
                  title: 'Outbox is Empty',
                  message: 'All local construction deliveries have been verified and synced with the central cloud ledger.',
                )
              else
                ...outbox.map((item) {
                  final isFailed = item.syncStatus == 'FAILED';
                  final isCompleted = item.syncStatus == 'COMPLETED';

                  Color statusColor = AppColors.amberWarning;
                  if (isCompleted) statusColor = AppColors.emeraldSuccess;
                  if (isFailed) statusColor = AppColors.redCritical;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.actionType.replaceAll('_', ' '),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.navyDark),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.syncStatus,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Key: ${item.idempotencyKey.substring(0, 16)}...',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Queued: ${Formatters.dateTime(item.createdAt)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              Text(
                                'Retries: ${item.retryCount}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          if (item.errorMessage != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Error: ${item.errorMessage}',
                              style: const TextStyle(fontSize: 11, color: AppColors.redCritical),
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
