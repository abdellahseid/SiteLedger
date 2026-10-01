import 'package:drift/drift.dart';
import '../../data/local/database.dart';
import '../../data/models/discrepancy_model.dart';
import '../../data/remote/api_client.dart';

class DiscrepancyRepository {
  final ApiClient api;
  final AppDatabase db;

  DiscrepancyRepository({required this.api, required this.db});

  Future<List<DiscrepancyModel>> getDiscrepancies({String? projectId, String? status, String? severity}) async {
    try {
      final queryParams = <String, String>{};
      if (projectId != null) queryParams['projectId'] = projectId;
      if (status != null) queryParams['status'] = status;
      if (severity != null) queryParams['severity'] = severity;

      final res = await api.get('/api/discrepancies', queryParams: queryParams);
      final list = (res['discrepancies'] as List).map((j) => DiscrepancyModel.fromJson(j)).toList();

      for (final d in list) {
        await db.into(db.cachedDiscrepancies).insert(
          CachedDiscrepanciesCompanion.insert(
            id: d.id,
            projectId: d.projectId,
            projectName: d.projectName,
            receiptId: d.receiptId,
            receiptNumber: d.receiptNumber,
            materialName: d.materialName,
            type: d.type,
            severity: d.severity,
            status: d.status,
            expectedQuantity: d.expectedQuantity,
            actualQuantity: d.actualQuantity,
            varianceQuantity: d.varianceQuantity,
            financialImpactEtb: d.financialImpactEtb,
            description: d.description,
            assignedToName: Value(d.assignedToName),
            resolutionNotes: Value(d.resolutionNotes),
            createdAt: d.createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
      return list;
    } catch (_) {
      final rows = await db.select(db.cachedDiscrepancies).get();
      return rows.map((r) => DiscrepancyModel(
        id: r.id,
        projectId: r.projectId,
        projectName: r.projectName,
        projectCode: 'SITE',
        receiptId: r.receiptId,
        receiptNumber: r.receiptNumber,
        waybillNumber: 'N/A',
        truckLicensePlate: 'N/A',
        poNumber: 'N/A',
        supplierName: 'Cached Supplier',
        materialName: r.materialName,
        materialUnit: 'Units',
        materialCode: 'MAT',
        type: r.type,
        severity: r.severity,
        status: r.status,
        expectedQuantity: r.expectedQuantity,
        actualQuantity: r.actualQuantity,
        varianceQuantity: r.varianceQuantity,
        financialImpactEtb: r.financialImpactEtb,
        description: r.description,
        assignedToName: r.assignedToName,
        resolutionNotes: r.resolutionNotes,
        createdAt: r.createdAt,
      )).toList();
    }
  }

  Future<({DiscrepancyModel discrepancy, AiInsightModel aiInsight})> getDiscrepancyDetails(String id) async {
    final res = await api.get('/api/discrepancies/$id');
    final discrepancy = DiscrepancyModel.fromJson(res['discrepancy']);
    final aiInsight = AiInsightModel.fromJson(res['aiInsight']);
    return (discrepancy: discrepancy, aiInsight: aiInsight);
  }

  Future<void> resolveDiscrepancy({
    required String id,
    required String resolutionType,
    required String resolutionNotes,
  }) async {
    await api.patch('/api/discrepancies/$id/resolve', body: {
      'resolutionType': resolutionType,
      'resolutionNotes': resolutionNotes,
    });
  }
}
