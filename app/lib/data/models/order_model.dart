class OrderLineModel {
  final String id;
  final String materialId;
  final String materialName;
  final String materialCode;
  final String unit;
  final double orderedQuantity;
  final double acceptedQuantity;
  final double unitPriceEtb;
  final double totalPriceEtb;

  OrderLineModel({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.materialCode,
    required this.unit,
    required this.orderedQuantity,
    required this.acceptedQuantity,
    required this.unitPriceEtb,
    required this.totalPriceEtb,
  });

  double get fulfillmentRate => orderedQuantity > 0 ? (acceptedQuantity / orderedQuantity).clamp(0.0, 1.0) : 0.0;
  double get remainingQuantity => (orderedQuantity - acceptedQuantity).clamp(0.0, double.infinity);

  factory OrderLineModel.fromJson(Map<String, dynamic> json) {
    return OrderLineModel(
      id: json['id'] ?? '',
      materialId: json['material_id'] ?? '',
      materialName: json['material_name'] ?? 'Material',
      materialCode: json['material_code'] ?? '',
      unit: json['unit'] ?? 'Units',
      orderedQuantity: num.tryParse(json['ordered_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      acceptedQuantity: num.tryParse(json['accepted_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      unitPriceEtb: num.tryParse(json['unit_price_etb']?.toString() ?? '0')?.toDouble() ?? 0.0,
      totalPriceEtb: num.tryParse(json['total_price_etb']?.toString() ?? '0')?.toDouble() ?? 0.0,
    );
  }
}

class PurchaseOrderModel {
  final String id;
  final String poNumber;
  final String projectId;
  final String projectName;
  final String projectCode;
  final String supplierId;
  final String supplierName;
  final String? supplierPhone;
  final String status; // DRAFT, PENDING_APPROVAL, APPROVED, PARTIALLY_RECEIVED, COMPLETED, CANCELLED
  final double totalAmountEtb;
  final int version;
  final String? notes;
  final String? createdByName;
  final String? approvedByName;
  final DateTime createdAt;
  final List<OrderLineModel> lines;

  PurchaseOrderModel({
    required this.id,
    required this.poNumber,
    required this.projectId,
    required this.projectName,
    required this.projectCode,
    required this.supplierId,
    required this.supplierName,
    this.supplierPhone,
    required this.status,
    required this.totalAmountEtb,
    this.version = 1,
    this.notes,
    this.createdByName,
    this.approvedByName,
    required this.createdAt,
    this.lines = const [],
  });

  bool get isApproved => status == 'APPROVED' || status == 'PARTIALLY_RECEIVED' || status == 'COMPLETED';
  bool get canReceive => status == 'APPROVED' || status == 'PARTIALLY_RECEIVED';

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json, {List<OrderLineModel> lines = const []}) {
    return PurchaseOrderModel(
      id: json['id'] ?? '',
      poNumber: json['po_number'] ?? '',
      projectId: json['project_id'] ?? '',
      projectName: json['project_name'] ?? '',
      projectCode: json['project_code'] ?? '',
      supplierId: json['supplier_id'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      supplierPhone: json['supplier_phone'],
      status: json['status'] ?? 'DRAFT',
      totalAmountEtb: num.tryParse(json['total_amount_etb']?.toString() ?? '0')?.toDouble() ?? 0.0,
      version: json['version'] ?? 1,
      notes: json['notes'],
      createdByName: json['created_by_name'],
      approvedByName: json['approved_by_name'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      lines: lines,
    );
  }
}
