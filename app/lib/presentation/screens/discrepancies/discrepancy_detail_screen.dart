import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/status_badge.dart';

class DiscrepancyDetailScreen extends ConsumerStatefulWidget {
  final String discrepancyId;

  const DiscrepancyDetailScreen({super.key, required this.discrepancyId});

  @override
  ConsumerState<DiscrepancyDetailScreen> createState() => _DiscrepancyDetailScreenState();
}

class _DiscrepancyDetailScreenState extends ConsumerState<DiscrepancyDetailScreen> {
  bool _isResolving = false;

  void _showResolutionDialog() {
    String selectedType = 'SUPPLIER_REPLACEMENT';
    final notesCtrl = TextEditingController(text: 'Supplier acknowledged variance on waybill. Replacement scheduled for next dispatch.');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Document Discrepancy Resolution', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select formal commercial resolution agreed with supplier:',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Resolution Type'),
                  items: const [
                    DropdownMenuItem(value: 'SUPPLIER_REPLACEMENT', child: Text('Supplier Replacement Batch')),
                    DropdownMenuItem(value: 'CREDIT_NOTE', child: Text('Payment Withheld / Credit Note')),
                    DropdownMenuItem(value: 'ACCEPTED_WITH_CONCESSION', child: Text('Accepted with Price Concession')),
                    DropdownMenuItem(value: 'REJECTED_RETURNED', child: Text('Rejected & Returned on Truck')),
                    DropdownMenuItem(value: 'CLAIM_FILED', child: Text('Carrier Freight Claim Filed')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Resolution Notes & Reference #'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldSuccess),
              onPressed: () async {
                Navigator.pop(ctx);
                _executeResolve(selectedType, notesCtrl.text.trim());
              },
              child: const Text('Confirm Resolution'),
            ),
          ],
        ),
      ),
    );
  }

  void _executeResolve(String type, String notes) async {
    setState(() => _isResolving = true);
    try {
      await ref.read(discrepancyRepoProvider).resolveDiscrepancy(
        id: widget.discrepancyId,
        resolutionType: type,
        resolutionNotes: notes,
      );
      ref.invalidate(discrepanciesProvider);
      ref.invalidate(dashboardMetricsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emeraldSuccess,
            content: Text('✅ Discrepancy resolved and documented in immutable ledger!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to resolve: $e')));
      }
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailFuture = ref.watch(discrepancyRepoProvider).getDiscrepancyDetails(widget.discrepancyId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discrepancy Audit Details'),
      ),
      body: FutureBuilder(
        future: detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading issue details: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final d = data.discrepancy;
          final ai = data.aiInsight;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              StatusBadge(status: d.type),
                              const SizedBox(width: 8),
                              StatusBadge(status: d.severity),
                            ],
                          ),
                          StatusBadge(status: d.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        d.materialName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Project: ${d.projectName} (${d.projectCode})',
                        style: const TextStyle(fontSize: 13, color: AppColors.electricBlue, fontWeight: FontWeight.w700),
                      ),
                      const Divider(height: 28),
                      _row('Supplier', d.supplierName, isDark),
                      _row('Waybill Number', d.waybillNumber, isDark),
                      _row('Truck License Plate', d.truckLicensePlate, isDark),
                      _row('Purchase Order', d.poNumber, isDark),
                      _row('Expected Quantity', '${d.expectedQuantity.toInt()} ${d.materialUnit}', isDark),
                      _row('Actual Received', '${d.actualQuantity.toInt()} ${d.materialUnit}', isDark),
                      _row('Variance Deficit', '${d.varianceQuantity.toInt()} ${d.materialUnit}', isDark),
                      _row('Financial Impact Exposure', Formatters.currency(d.financialImpactEtb), isDark),
                      if (d.assignedToName != null) _row('Assigned To', d.assignedToName!, isDark),
                      if (d.resolutionType != null) _row('Resolution Type', d.resolutionType!.replaceAll('_', ' '), isDark),
                      if (d.resolutionNotes != null) _row('Resolution Agreement', d.resolutionNotes!, isDark),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceWarm,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderSubtle),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.rate_review_outlined, size: 18, color: AppColors.textMuted),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Storekeeper Observation: "${d.description}"',
                                style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Gemini AI Discrepancy Intelligence Card
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.heroCardGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                gradient: AppGradients.aiGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Gemini AI Contract Intelligence',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ai.isAiGenerated ? 'Gemini 1.5 Flash' : 'Expert Rule Engine',
                            style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Commercial & Schedule Risk Analysis:',
                      style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ai.explanation,
                      style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Recommended Action (FIDIC / PPA Standard):',
                      style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ai.recommendedAction,
                      style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.45),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SiteLedger AI assists decision-making; final contractual sign-off remains with authorized project personnel.',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10.5, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Document Resolution Action
              if (d.isOpen)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldSuccess,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isResolving ? null : _showResolutionDialog,
                  icon: const Icon(Icons.handshake_outlined),
                  label: _isResolving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Document Agreed Resolution', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

