class DiscrepancyModel {
  final String id;
  final String projectId;
  final String projectName;
  final String projectCode;
  final String receiptId;
  final String receiptNumber;
  final String waybillNumber;
  final String truckLicensePlate;
  final String poNumber;
  final String supplierName;
  final String materialName;
  final String materialUnit;
  final String materialCode;
  final String type; // SHORTAGE, EXCESS, DAMAGE, SPECIFICATION_MISMATCH
  final String severity; // LOW, MEDIUM, HIGH, CRITICAL
  final String status; // OPEN, UNDER_REVIEW, RESOLVED, DISMISSED
  final double expectedQuantity;
  final double actualQuantity;
  final double varianceQuantity;
  final double financialImpactEtb;
  final String description;
  final String? assignedToName;
  final String? resolutionType;
  final String? resolutionNotes;
  final String? resolvedByName;
  final DateTime createdAt;

  DiscrepancyModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.projectCode,
    required this.receiptId,
    required this.receiptNumber,
    required this.waybillNumber,
    required this.truckLicensePlate,
    required this.poNumber,
    required this.supplierName,
    required this.materialName,
    required this.materialUnit,
    required this.materialCode,
    required this.type,
    required this.severity,
    required this.status,
    required this.expectedQuantity,
    required this.actualQuantity,
    required this.varianceQuantity,
    required this.financialImpactEtb,
    required this.description,
    this.assignedToName,
    this.resolutionType,
    this.resolutionNotes,
    this.resolvedByName,
    required this.createdAt,
  });

  bool get isOpen => status == 'OPEN' || status == 'UNDER_REVIEW';
  bool get isResolved => status == 'RESOLVED';
  bool get isCritical => severity == 'CRITICAL' || severity == 'HIGH';

  factory DiscrepancyModel.fromJson(Map<String, dynamic> json) {
    return DiscrepancyModel(
      id: json['id'] ?? '',
      projectId: json['project_id'] ?? '',
      projectName: json['project_name'] ?? '',
      projectCode: json['project_code'] ?? '',
      receiptId: json['receipt_id'] ?? '',
      receiptNumber: json['receipt_number'] ?? '',
      waybillNumber: json['waybill_number'] ?? '',
      truckLicensePlate: json['truck_license_plate'] ?? '',
      poNumber: json['po_number'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      materialName: json['material_name'] ?? 'Material',
      materialUnit: json['material_unit'] ?? 'Units',
      materialCode: json['material_code'] ?? '',
      type: json['type'] ?? 'SHORTAGE',
      severity: json['severity'] ?? 'MEDIUM',
      status: json['status'] ?? 'OPEN',
      expectedQuantity: num.tryParse(json['expected_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      actualQuantity: num.tryParse(json['actual_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      varianceQuantity: num.tryParse(json['variance_quantity']?.toString() ?? '0')?.toDouble() ?? 0.0,
      financialImpactEtb: num.tryParse(json['financial_impact_etb']?.toString() ?? '0')?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      assignedToName: json['assigned_to_name'],
      resolutionType: json['resolution_type'],
      resolutionNotes: json['resolution_notes'],
      resolvedByName: json['resolved_by_name'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

class AiInsightModel {
  final String explanation;
  final String recommendedAction;
  final bool isAiGenerated;

  AiInsightModel({
    required this.explanation,
    required this.recommendedAction,
    this.isAiGenerated = true,
  });

  factory AiInsightModel.fromJson(Map<String, dynamic> json) {
    return AiInsightModel(
      explanation: json['explanation'] ?? 'Assessment in progress.',
      recommendedAction: json['recommendedAction'] ?? json['recommended_action'] ?? 'Verify quantities on site.',
      isAiGenerated: json['isAiGenerated'] ?? json['is_ai_generated'] ?? false,
    );
  }
}
