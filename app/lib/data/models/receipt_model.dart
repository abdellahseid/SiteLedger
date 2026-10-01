class ReceiptLineModel {
  final String id;
  final String materialId;
  final String materialName;
  final String unit;
  final double orderedQuantity;
  final double deliveredQuantity;
  final double acceptedQuantity;
  final double damagedQuantity;
  final double rejectedQuantity;
  final String? rejectionReason;
  final double unitPriceEtb;

  ReceiptLineModel({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.unit,
    required this.orderedQuantity,
    required this.deliveredQuantity,
    required this.acceptedQuantity,
    required this.damagedQuantity,
    required this.rejectedQuantity,
    this.rejectionReason,
    this.unitPriceEtb = 0.0,
  });

  bool get hasShortage => deliveredQuantity < orderedQuantity;
  bool get hasDamage => damagedQuantity > 0;

  factory ReceiptLineModel.fromJson(Map<String, dynamic> json) {
    return ReceiptLineModel(
      id: json['id'] ?? '',
      materialId: json['material_id'] ?? '',
      materialName: json['material_name'] ?? 'Material',
      unit: json['unit'] ?? 'Units',
      orderedQuantity: num.tryParse(json['ordered_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      deliveredQuantity: num.tryParse(json['delivered_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      acceptedQuantity: num.tryParse(json['accepted_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      damagedQuantity: num.tryParse(json['damaged_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      rejectedQuantity: num.tryParse(json['rejected_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      rejectionReason: json['rejection_reason'],
      unitPriceEtb: num.tryParse(json['unit_price_etb']?.toString() ?? '0')?.toDouble() ?? 0.0,
    );
  }
}

class EvidenceModel {
  final String id;
  final String photoType;
  final String fileUrl;
  final String? caption;
  final DateTime capturedAt;

  EvidenceModel({
    required this.id,
    required this.photoType,
    required this.fileUrl,
    this.caption,
    required this.capturedAt,
  });

  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    return EvidenceModel(
      id: json['id'] ?? '',
      photoType: json['photo_type'] ?? 'MATERIAL_OVERVIEW',
      fileUrl: json['file_url'] ?? '',
      caption: json['caption'],
      capturedAt: json['captured_at'] != null ? DateTime.parse(json['captured_at']) : DateTime.now(),
    );
  }
}

class ReceiptModel {
  final String id;
  final String receiptNumber;
  final String poId;
  final String poNumber;
  final String projectId;
  final String projectName;
  final String projectCode;
  final String supplierName;
  final String waybillNumber;
  final String truckLicensePlate;
  final String driverName;
  final String? driverPhone;
  final String? carrierName;
  final String? storekeeperName;
  final String status; // SUBMITTED, VERIFIED, FLAGGED
  final String? notes;
  final DateTime deliveryTimestamp;
  final int totalItems;
  final double totalAcceptedQuantity;
  final double totalDamagedQuantity;
  final int discrepancyCount;
  final int evidenceCount;
  final List<ReceiptLineModel> lines;
  final List<EvidenceModel> evidence;

  ReceiptModel({
    required this.id,
    required this.receiptNumber,
    required this.poId,
    required this.poNumber,
    required this.projectId,
    required this.projectName,
    required this.projectCode,
    required this.supplierName,
    required this.waybillNumber,
    required this.truckLicensePlate,
    required this.driverName,
    this.driverPhone,
    this.carrierName,
    this.storekeeperName,
    required this.status,
    this.notes,
    required this.deliveryTimestamp,
    this.totalItems = 0,
    this.totalAcceptedQuantity = 0.0,
    this.totalDamagedQuantity = 0.0,
    this.discrepancyCount = 0,
    this.evidenceCount = 0,
    this.lines = const [],
    this.evidence = const [],
  });

  bool get isFlagged => status == 'FLAGGED' || discrepancyCount > 0;

  factory ReceiptModel.fromJson(Map<String, dynamic> json, {List<ReceiptLineModel> lines = const [], List<EvidenceModel> evidence = const []}) {
    return ReceiptModel(
      id: json['id'] ?? '',
      receiptNumber: json['receipt_number'] ?? '',
      poId: json['purchase_order_id'] ?? json['po_id'] ?? '',
      poNumber: json['po_number'] ?? '',
      projectId: json['project_id'] ?? '',
      projectName: json['project_name'] ?? '',
      projectCode: json['project_code'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      waybillNumber: json['waybill_number'] ?? '',
      truckLicensePlate: json['truck_license_plate'] ?? '',
      driverName: json['driver_name'] ?? '',
      driverPhone: json['driver_phone'],
      carrierName: json['carrier_name'],
      storekeeperName: json['storekeeper_name'],
      status: json['status'] ?? 'SUBMITTED',
      notes: json['notes'],
      deliveryTimestamp: json['delivery_timestamp'] != null ? DateTime.parse(json['delivery_timestamp']) : DateTime.now(),
      totalItems: int.tryParse(json['total_items']?.toString() ?? '0') ?? 0,
      totalAcceptedQuantity: num.tryParse(json['total_accepted_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      totalDamagedQuantity: num.tryParse(json['total_damaged_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      discrepancyCount: int.tryParse(json['discrepancy_count']?.toString() ?? '0') ?? 0,
      evidenceCount: int.tryParse(json['evidence_count']?.toString() ?? '0') ?? 0,
      lines: lines,
      evidence: evidence,
    );
  }
}
