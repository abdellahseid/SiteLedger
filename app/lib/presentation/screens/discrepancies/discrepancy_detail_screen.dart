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
          title: const Text('Document Discrepancy Resolution'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select formal commercial resolution agreed with supplier:',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
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
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
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
                      const SizedBox(height: 14),
                      Text(
                        d.materialName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Project: ${d.projectName} (${d.projectCode})',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const Divider(height: 24),
                      _row('Supplier', d.supplierName),
                      _row('Waybill Number', d.waybillNumber),
                      _row('Truck License Plate', d.truckLicensePlate),
                      _row('Purchase Order', d.poNumber),
                      _row('Expected Quantity', '${d.expectedQuantity.toInt()} ${d.materialUnit}'),
                      _row('Actual Received', '${d.actualQuantity.toInt()} ${d.materialUnit}'),
                      _row('Variance Deficit', '${d.varianceQuantity.toInt()} ${d.materialUnit}'),
                      _row('Financial Exposure', Formatters.currency(d.financialImpactEtb)),
                      if (d.assignedToName != null) _row('Assigned To', d.assignedToName!),
                      if (d.resolutionType != null) _row('Resolution Type', d.resolutionType!.replaceAll('_', ' ')),
                      if (d.resolutionNotes != null) _row('Resolution Agreement', d.resolutionNotes!),
                      const SizedBox(height: 8),
                      Text(
                        'Site Inspector Observation: "${d.description}"',
                        style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Gemini AI Discrepancy Intelligence Card
              Card(
                color: const Color(0xFF0F172A),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.electricBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Gemini AI Delivery Intelligence',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.5),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ai.isAiGenerated ? 'Gemini 1.5 Flash' : 'Expert Rule Engine',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Commercial & Schedule Impact:',
                        style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ai.explanation,
                        style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Recommended Contractual Action (FIDIC / PPA):',
                        style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ai.recommendedAction,
                        style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'SiteLedger AI assists decision-making; final contractual sign-off remains with authorized project personnel.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyDark),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
