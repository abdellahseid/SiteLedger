import 'package:drift/drift.dart';
import '../../data/local/database.dart';
import '../../data/models/receipt_model.dart';
import '../../data/remote/api_client.dart';
import 'sync_manager.dart';

class ReceiptRepository {
  final ApiClient api;
  final AppDatabase db;
  final SyncManager syncManager;

  ReceiptRepository({required this.api, required this.db, required this.syncManager});

  Future<List<ReceiptModel>> getReceipts({String? projectId, String? poId}) async {
    try {
      final queryParams = <String, String>{};
      if (projectId != null) queryParams['projectId'] = projectId;
      if (poId != null) queryParams['poId'] = poId;

      final res = await api.get('/api/receipts', queryParams: queryParams);
      final list = (res['receipts'] as List).map((j) => ReceiptModel.fromJson(j)).toList();

      // Cache into Drift SQLite in background
      for (final r in list) {
        await db.into(db.cachedReceipts).insert(
          CachedReceiptsCompanion.insert(
            id: r.id,
            receiptNumber: r.receiptNumber,
            poId: r.poId,
            poNumber: r.poNumber,
            projectId: r.projectId,
            projectName: r.projectName,
            supplierName: r.supplierName,
            waybillNumber: r.waybillNumber,
            truckLicensePlate: r.truckLicensePlate,
            driverName: r.driverName,
            status: r.status,
            notes: Value(r.notes),
            deliveryTimestamp: r.deliveryTimestamp,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }

      return list;
    } catch (_) {
      // Offline fallback: load from Drift
      final rows = await db.select(db.cachedReceipts).get();
      return rows.map((r) => ReceiptModel(
        id: r.id,
        receiptNumber: r.receiptNumber,
        poId: r.poId,
        poNumber: r.poNumber,
        projectId: r.projectId,
        projectName: r.projectName,
        projectCode: 'SITE',
        supplierName: r.supplierName,
        waybillNumber: r.waybillNumber,
        truckLicensePlate: r.truckLicensePlate,
        driverName: r.driverName,
        status: r.status,
        notes: r.notes,
        deliveryTimestamp: r.deliveryTimestamp,
      )).toList();
    }
  }

  Future<ReceiptModel> getReceiptDetails(String id) async {
    final res = await api.get('/api/receipts/$id');
    final lines = (res['lines'] as List? ?? []).map((j) => ReceiptLineModel.fromJson(j)).toList();
    final evidence = (res['evidence'] as List? ?? []).map((j) => EvidenceModel.fromJson(j)).toList();
    return ReceiptModel.fromJson(res['receipt'], lines: lines, evidence: evidence);
  }

  // Create receipt online or queue to Drift outbox if offline
  Future<({bool isOfflineQueued, dynamic result})> createReceipt(Map<String, dynamic> payload) async {
    try {
      final res = await api.post('/api/receipts', body: payload);
      return (isOfflineQueued: false, result: res);
    } catch (e) {
      // Queue in local outbox
      final idempotencyKey = payload['idempotencyKey'] ?? 'idemp-offline-${DateTime.now().millisecondsSinceEpoch}';
      await syncManager.enqueueReceipt(idempotencyKey: idempotencyKey, payload: payload);
      return (isOfflineQueued: true, result: null);
    }
  }
}
