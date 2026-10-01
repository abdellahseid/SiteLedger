import 'package:flutter_test/flutter_test.dart';
import 'package:siteledger/core/utils/formatters.dart';
import 'package:siteledger/data/models/order_model.dart';
import 'package:siteledger/data/models/receipt_model.dart';
import 'package:siteledger/data/models/discrepancy_model.dart';

void main() {
  group('SiteLedger Domain and Formatting Tests', () {
    test('Formatters format Ethiopian Birr currency correctly', () {
      expect(Formatters.currency(1350), 'ETB 1,350.00');
      expect(Formatters.currency(2700000, compact: true), 'ETB 2.7M');
      expect(Formatters.currency(67500), 'ETB 67,500.00');
    });

    test('Formatters format material quantities with units', () {
      expect(Formatters.quantity(1000, 'Bags'), '1000 Bags');
      expect(Formatters.quantity(20.5, 'Tonnes'), '20.5 Tonnes');
    });

    test('PurchaseOrderModel deserializes and computes progress accurately', () {
      final po = PurchaseOrderModel(
        id: 'po-1',
        poNumber: 'PO-2026-BLIP-001',
        projectId: 'proj-1',
        projectName: 'Bole Lemi',
        projectCode: 'BLIP-02',
        supplierId: 'sup-1',
        supplierName: 'Muger Cement',
        status: 'PARTIALLY_RECEIVED',
        totalAmountEtb: 2700000.0,
        createdAt: DateTime.now(),
        lines: [
          OrderLineModel(
            id: 'line-1',
            materialId: 'mat-1',
            materialName: 'PPC 42.5R Cement',
            materialCode: 'MAT-CEM-01',
            unit: 'Bags',
            orderedQuantity: 2000.0,
            acceptedQuantity: 920.0,
            unitPriceEtb: 1350.0,
            totalPriceEtb: 2700000.0,
          ),
        ],
      );

      expect(po.canReceive, isTrue);
      expect(po.isApproved, isTrue);
      expect(po.lines.first.remainingQuantity, 1080.0);
      expect(po.lines.first.fulfillmentRate, closeTo(0.46, 0.01));
    });

    test('ReceiptModel tracks shortage and damage status', () {
      final receipt = ReceiptModel(
        id: 'rec-1',
        receiptNumber: 'REC-2026-001',
        poId: 'po-1',
        poNumber: 'PO-2026-BLIP-001',
        projectId: 'proj-1',
        projectName: 'Bole Lemi',
        projectCode: 'BLIP-02',
        supplierName: 'Muger Cement',
        waybillNumber: 'WB-MUG-89412',
        truckLicensePlate: 'ET-3-84920-AA',
        driverName: 'Tewodros Kassahun',
        status: 'FLAGGED',
        deliveryTimestamp: DateTime.now(),
        discrepancyCount: 2,
        totalAcceptedQuantity: 920.0,
        totalDamagedQuantity: 30.0,
      );

      expect(receipt.isFlagged, isTrue);
      expect(receipt.totalAcceptedQuantity, 920.0);
      expect(receipt.totalDamagedQuantity, 30.0);
    });

    test('DiscrepancyModel flags severity and openness', () {
      final disc = DiscrepancyModel(
        id: 'disc-1',
        projectId: 'proj-1',
        projectName: 'Bole Lemi',
        projectCode: 'BLIP-02',
        receiptId: 'rec-1',
        receiptNumber: 'REC-2026-001',
        waybillNumber: 'WB-MUG-89412',
        truckLicensePlate: 'ET-3-84920',
        poNumber: 'PO-2026-BLIP-001',
        supplierName: 'Muger Cement',
        materialName: 'Cement PPC 42.5R',
        materialUnit: 'Bags',
        materialCode: 'MAT-CEM-01',
        type: 'SHORTAGE',
        severity: 'HIGH',
        status: 'UNDER_REVIEW',
        expectedQuantity: 1000.0,
        actualQuantity: 950.0,
        varianceQuantity: -50.0,
        financialImpactEtb: 67500.0,
        description: '50 bags shortage',
        createdAt: DateTime.now(),
      );

      expect(disc.isOpen, isTrue);
      expect(disc.isCritical, isTrue);
      expect(disc.financialImpactEtb, 67500.0);
    });
  });
}
