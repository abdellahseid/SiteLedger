class ProjectModel {
  final String id;
  final String code;
  final String name;
  final String location;
  final String? description;
  final String status;
  final double budgetEtb;
  final int totalOrders;
  final int totalReceipts;
  final int openDiscrepancies;
  final double discrepancyImpactEtb;

  ProjectModel({
    required this.id,
    required this.code,
    required this.name,
    required this.location,
    this.description,
    required this.status,
    required this.budgetEtb,
    this.totalOrders = 0,
    this.totalReceipts = 0,
    this.openDiscrepancies = 0,
    this.discrepancyImpactEtb = 0.0,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'ACTIVE',
      budgetEtb: (json['budget_etb'] != null ? num.tryParse(json['budget_etb'].toString())?.toDouble() : 0.0) ?? 0.0,
      totalOrders: int.tryParse(json['total_orders']?.toString() ?? '0') ?? 0,
      totalReceipts: int.tryParse(json['total_receipts']?.toString() ?? '0') ?? 0,
      openDiscrepancies: int.tryParse(json['open_discrepancies']?.toString() ?? '0') ?? 0,
      discrepancyImpactEtb: (json['discrepancy_impact_etb'] != null ? num.tryParse(json['discrepancy_impact_etb'].toString())?.toDouble() : 0.0) ?? 0.0,
    );
  }
}
