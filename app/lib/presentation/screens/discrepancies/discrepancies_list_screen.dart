import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class DiscrepanciesListScreen extends ConsumerStatefulWidget {
  const DiscrepanciesListScreen({super.key});

  @override
  ConsumerState<DiscrepanciesListScreen> createState() => _DiscrepanciesListScreenState();
}

class _DiscrepanciesListScreenState extends ConsumerState<DiscrepanciesListScreen> {
  String _selectedTab = 'ALL';

  @override
  Widget build(BuildContext context) {
    final discrepanciesAsync = ref.watch(discrepanciesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discrepancy Issues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Gemini AI Insights',
            onPressed: () => context.push('/reports'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _tabChip('ALL', 'All Issues'),
                const SizedBox(width: 8),
                _tabChip('OPEN', 'Open Variances'),
                const SizedBox(width: 8),
                _tabChip('UNDER_REVIEW', 'Under Review'),
                const SizedBox(width: 8),
                _tabChip('RESOLVED', 'Resolved & Settled'),
              ],
            ),
          ),

          Expanded(
            child: discrepanciesAsync.when(
              data: (discrepancies) {
                final filtered = discrepancies.where((d) {
                  if (_selectedTab == 'ALL') return true;
                  return d.status == _selectedTab;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.verified_outlined,
                    title: 'No Discrepancies Found',
                    message: _selectedTab == 'ALL'
                        ? 'All site material deliveries match authorized purchase order specifications.'
                        : 'No discrepancies currently in "$_selectedTab" status.',
                  );
                }

                final totalExposure = filtered.fold<double>(0.0, (acc, d) => acc + d.financialImpactEtb);

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(discrepanciesProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                    children: [
                      // Exposure Ticker Card
                      if (_selectedTab == 'ALL' || _selectedTab == 'OPEN')
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.redBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.redBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.redCritical.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.shield_outlined, color: AppColors.redCritical, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Active Commercial Risk Exposure',
                                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.redDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      Formatters.currency(totalExposure),
                                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.redCritical),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.redCritical,
                                  side: const BorderSide(color: AppColors.redCritical),
                                  minimumSize: const Size(0, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () => context.push('/reports'),
                                child: const Text('AI Audit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),

                      ...filtered.map((d) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => context.push('/issues/${d.id}'),
                            borderRadius: BorderRadius.circular(20),
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
                                          StatusBadge(status: d.type, isSmall: true),
                                          const SizedBox(width: 8),
                                          StatusBadge(status: d.severity, isSmall: true),
                                        ],
                                      ),
                                      StatusBadge(status: d.status, isSmall: true),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    d.materialName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Supplier: ${d.supplierName} • Waybill: ${d.waybillNumber}',
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceWarm,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      d.description,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.navyDark,
                                        height: 1.35,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Divider(height: 22),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            d.varianceQuantity < 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                                            size: 16,
                                            color: d.varianceQuantity < 0 ? AppColors.redCritical : AppColors.amberWarning,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Variance: ${d.varianceQuantity.toInt()} ${d.materialUnit}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              color: d.varianceQuantity < 0 ? AppColors.redCritical : AppColors.amberWarning,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        Formatters.currency(d.financialImpactEtb),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading issues: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip(String code, String label) {
    final isSelected = _selectedTab == code;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.navyDark,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.navyDark,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => setState(() => _selectedTab = code),
    );
  }
}

