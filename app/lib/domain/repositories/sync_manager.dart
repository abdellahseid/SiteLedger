import 'dart:convert';
import 'package:drift/drift.dart';
import '../../data/local/database.dart';
import '../../data/remote/api_client.dart';

class SyncResult {
  final int syncedCount;
  final int failedCount;
  final String message;

  SyncResult({required this.syncedCount, required this.failedCount, required this.message});
}

class SyncManager {
  final AppDatabase db;
  final ApiClient api;

  SyncManager({required this.db, required this.api});

  // Get pending count stream from Drift
  Stream<int> watchPendingCount() {
    final query = db.select(db.syncOutbox)..where((t) => t.syncStatus.isIn(['PENDING', 'FAILED']));
    return query.watch().map((rows) => rows.length);
  }

  Future<List<SyncOutboxData>> getOutboxItems() async {
    final query = db.select(db.syncOutbox)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return await query.get();
  }

  // Enqueue a receipt creation action when offline
  Future<void> enqueueReceipt({
    required String idempotencyKey,
    required Map<String, dynamic> payload,
  }) async {
    await db.into(db.syncOutbox).insert(
      SyncOutboxCompanion.insert(
        idempotencyKey: idempotencyKey,
        actionType: 'RECEIVE_DELIVERY',
        payloadJson: jsonEncode(payload),
        syncStatus: const Value('PENDING'),
        createdAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  // Attempt to flush and synchronize all pending items in outbox
  Future<SyncResult> syncAllPending() async {
    final pendingItems = await (db.select(db.syncOutbox)
      ..where((t) => t.syncStatus.isIn(['PENDING', 'FAILED']))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();

    if (pendingItems.isEmpty) {
      return SyncResult(syncedCount: 0, failedCount: 0, message: 'All local records are synchronized.');
    }

    int synced = 0;
    int failed = 0;

    for (final item in pendingItems) {
      try {
        // Mark as syncing
        await (db.update(db.syncOutbox)..where((t) => t.id.equals(item.id))).write(
          SyncOutboxCompanion(
            syncStatus: const Value('SYNCING'),
            lastAttemptAt: Value(DateTime.now()),
            retryCount: Value(item.retryCount + 1),
          ),
        );

        final payload = jsonDecode(item.payloadJson);
        await api.post('/api/receipts', body: payload);

        // Mark completed
        await (db.update(db.syncOutbox)..where((t) => t.id.equals(item.id))).write(
          const SyncOutboxCompanion(
            syncStatus: Value('COMPLETED'),
            errorMessage: Value(null),
          ),
        );
        synced++;
      } catch (err) {
        failed++;
        await (db.update(db.syncOutbox)..where((t) => t.id.equals(item.id))).write(
          SyncOutboxCompanion(
            syncStatus: const Value('FAILED'),
            errorMessage: Value(err.toString()),
          ),
        );
      }
    }

    return SyncResult(
      syncedCount: synced,
      failedCount: failed,
      message: synced > 0 ? 'Synchronized $synced deliveries successfully.' : 'Sync failed. Local copies preserved.',
    );
  }
}
