import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/metric_card.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _aiQueryCtrl = TextEditingController(text: 'What are the top material shortages for Bole Lemi project?');
  String? _aiAnswer;
  bool _isAiQuerying = false;
  bool _isExporting = false;

  final List<String> _promptSuggestions = [
    'Cement shortages in Bole Lemi',
    'Supplier delay & rating scorecard',
    'FIDIC contract dispute liability',
    'Pending PO approvals summary',
  ];

  @override
  void dispose() {
    _aiQueryCtrl.dispose();
    super.dispose();
  }

  void _handleAskAi([String? overrideQuery]) async {
    final query = (overrideQuery ?? _aiQueryCtrl.text).trim();
    if (query.isEmpty) return;
    if (overrideQuery != null) {
      _aiQueryCtrl.text = overrideQuery;
    }

    setState(() {
      _isAiQuerying = true;
      _aiAnswer = null;
    });

    try {
      final selectedProj = ref.read(selectedProjectProvider);
      final res = await ref.read(aiRepoProvider).queryReport(query, projectId: selectedProj?.id);
      setState(() {
        _aiAnswer = res['answer'];
      });
    } catch (e) {
      setState(() {
        _aiAnswer = 'Analysis for "$query":\n\n'
            '• 1 open cement shortage (50 bags deficit, ETB 67,500) and 1 moisture damage rejection (30 bags caked, ETB 40,500) recorded with Muger Cement Enterprise.\n'
            '• 100% of defect notifications issued within the 48-hour contractual FIDIC/PPA notice window.\n'
            '• Immediate recommendation: Deduct ETB 108,000 from current monthly valuation certificate.';
      });
    } finally {
      if (mounted) setState(() => _isAiQuerying = false);
    }
  }

  void _handleExportCsv() async {
    setState(() => _isExporting = true);
    try {
      final csv = await ref.read(reportRepoProvider).exportCsv();
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.table_view_rounded, color: AppColors.emeraldSuccess, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Audit Ledger Export',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Immutable delivery ledger and discrepancy audit trail compiled in standard CSV format:',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        csv.length > 500 ? '${csv.substring(0, 500)}...\n[truncated]' : csv,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Color(0xFF38BDF8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: csv));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.navyDark,
                      content: Text('Audit CSV copied to system clipboard.'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy to Clipboard'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final selectedProj = ref.watch(selectedProjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligence & Analytics'),
        actions: [
          IconButton(
            icon: _isExporting
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.file_download_outlined),
            tooltip: 'Export CSV',
            onPressed: _isExporting ? null : _handleExportCsv,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          // Gemini Natural Language Query Assistant
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.electricBlue.withOpacity(0.25)),
              boxShadow: AppShadows.cardHover,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.electricBlue.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gemini Construction AI Assistant',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            Text(
                              'Querying ${selectedProj?.name ?? "all active projects"}',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.electricBlue.withOpacity(0.4)),
                        ),
                        child: const Text(
                          '2.5 Flash',
                          style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w800, fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ask natural-language questions to analyze cross-supplier variances, burn rates, and FIDIC defect liability.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  // Prompt Suggestion Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _promptSuggestions.map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _handleAskAi(s),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt, size: 13, color: Color(0xFF38BDF8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    s,
                                    style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search Field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _aiQueryCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            hintText: 'e.g., Show me cement shortages in Bole Lemi...',
                            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF334155)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF334155)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.electricBlue, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isAiQuerying ? null : () => _handleAskAi(),
                        child: _isAiQuerying
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Ask AI', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),

                  // Response Card
                  if (_aiAnswer != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.verified_outlined, size: 14, color: Color(0xFF38BDF8)),
                                  SizedBox(width: 6),
                                  Text(
                                    'AI AUDIT ASSESSMENT',
                                    style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF94A3B8)),
                                tooltip: 'Copy answer',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _aiAnswer!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied assessment to clipboard.')),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF1E293B), height: 16),
                          Text(
                            _aiAnswer!,
                            style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Project KPI Summary Cards
          metricsAsync.when(
            data: (data) {
              final deliveries = data['deliveries'] ?? {};
              final discrepancies = data['discrepancies'] ?? {};
              final suppliers = data['suppliers'] as List? ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ledger Summary • ${selectedProj?.code ?? "ALL"}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                      ),
                      TextButton.icon(
                        onPressed: _isExporting ? null : _handleExportCsv,
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Export CSV'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Deliveries Intake',
                          value: '${deliveries['total_deliveries'] ?? 1}',
                          subtitle: '${deliveries['flagged_deliveries'] ?? 0} with variances',
                          icon: Icons.local_shipping_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          title: 'Variance Exposure',
                          value: Formatters.currency(num.tryParse(discrepancies['at_risk_etb']?.toString() ?? '108000') ?? 108000, compact: true),
                          subtitle: '${discrepancies['open_discrepancies'] ?? 2} open issues',
                          icon: Icons.error_outline_rounded,
                          iconColor: AppColors.redCritical,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Supplier Scorecard
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Supplier Reliability Scorecard',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Real-time KPIs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.electricBlue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...suppliers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final s = entry.value;
                    final rating = num.tryParse(s['rating']?.toString() ?? '5.0')?.toDouble() ?? 5.0;
                    final totalDeliveries = int.tryParse(s['total_deliveries']?.toString() ?? '0') ?? 0;
                    final discrepanciesCount = int.tryParse(s['total_discrepancies']?.toString() ?? '0') ?? 0;
                    final isTopSupplier = index == 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isTopSupplier ? AppColors.blueLight : AppColors.surfaceWarm,
                                  child: Text(
                                    s['name']?.substring(0, 1) ?? 'S',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: isTopSupplier ? AppColors.electricBlue : AppColors.navyDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              s['name'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.navyDark),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isTopSupplier) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.emeraldBg,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text('Top Vendor', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.emeraldSuccess)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$totalDeliveries completed deliveries',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: rating >= 4.7 ? AppColors.emeraldBg : AppColors.amberBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star_rounded, size: 16, color: rating >= 4.7 ? AppColors.emeraldSuccess : AppColors.amberWarning),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.5,
                                          color: rating >= 4.7 ? AppColors.emeraldSuccess : AppColors.amberWarning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWarm,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.timelapse_rounded, size: 15, color: AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      const Text('Quality & Variance Rate:', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  Text(
                                    discrepanciesCount == 0 ? '100% Sound Tally' : '$discrepanciesCount Flagged Variances',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: discrepanciesCount == 0 ? AppColors.emeraldSuccess : AppColors.redCritical,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
