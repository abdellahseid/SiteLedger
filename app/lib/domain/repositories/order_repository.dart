import 'package:drift/drift.dart';
import '../../data/local/database.dart';
import '../../data/models/order_model.dart';
import '../../data/remote/api_client.dart';

class OrderRepository {
  final ApiClient api;
  final AppDatabase db;

  OrderRepository({required this.api, required this.db});

  Future<List<PurchaseOrderModel>> getOrders({String? projectId, String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (projectId != null) queryParams['projectId'] = projectId;
      if (status != null) queryParams['status'] = status;

      final res = await api.get('/api/orders', queryParams: queryParams);
      final list = (res['orders'] as List).map((j) => PurchaseOrderModel.fromJson(j)).toList();

      // Cache into Drift
      for (final po in list) {
        await db.into(db.cachedOrders).insert(
          CachedOrdersCompanion.insert(
            id: po.id,
            projectId: po.projectId,
            poNumber: po.poNumber,
            supplierName: po.supplierName,
            status: po.status,
            totalAmountEtb: po.totalAmountEtb,
            version: Value(po.version),
            notes: Value(po.notes),
            createdAt: po.createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }

      return list;
    } catch (_) {
      // Load cached from Drift
      final rows = await db.select(db.cachedOrders).get();
      return rows.map((r) => PurchaseOrderModel(
        id: r.id,
        poNumber: r.poNumber,
        projectId: r.projectId,
        projectName: 'Active Project',
        projectCode: 'SITE',
        supplierId: '',
        supplierName: r.supplierName,
        status: r.status,
        totalAmountEtb: r.totalAmountEtb,
        version: r.version,
        notes: r.notes,
        createdAt: r.createdAt,
      )).toList();
    }
  }

  Future<PurchaseOrderModel> getOrderDetails(String id) async {
    final res = await api.get('/api/orders/$id');
    final lines = (res['lines'] as List? ?? []).map((j) => OrderLineModel.fromJson(j)).toList();
    return PurchaseOrderModel.fromJson(res['order'], lines: lines);
  }

  // QR Code Site Lookup
  Future<PurchaseOrderModel> getOrderByNumber(String poNumber) async {
    final res = await api.get('/api/orders/by-number/$poNumber');
    final lines = (res['lines'] as List? ?? []).map((j) => OrderLineModel.fromJson(j)).toList();
    return PurchaseOrderModel.fromJson(res['order'], lines: lines);
  }

  Future<PurchaseOrderModel> createOrder(Map<String, dynamic> payload) async {
    final res = await api.post('/api/orders', body: payload);
    final lines = (res['lines'] as List? ?? []).map((j) => OrderLineModel.fromJson(j)).toList();
    return PurchaseOrderModel.fromJson(res['order'], lines: lines);
  }

  Future<void> approveOrder(String id) async {
    await api.patch('/api/orders/$id/approve');
  }
}
