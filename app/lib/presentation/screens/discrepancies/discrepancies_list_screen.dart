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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discrepancy Issues'),
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
                _tabChip('OPEN', 'Open'),
                const SizedBox(width: 8),
                _tabChip('UNDER_REVIEW', 'Under Review'),
                const SizedBox(width: 8),
                _tabChip('RESOLVED', 'Resolved'),
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
                    title: 'No Discrepancies',
                    message: _selectedTab == 'ALL'
                        ? 'All deliveries match authorized purchase order specifications.'
                        : 'No discrepancies currently in "$_selectedTab" status.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(discrepanciesProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final d = filtered[idx];
                      return Card(
                        child: InkWell(
                          onTap: () => context.push('/issues/${d.id}'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
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
                                const SizedBox(height: 10),
                                Text(
                                  d.materialName,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.navyDark),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Supplier: ${d.supplierName} • Waybill: ${d.waybillNumber}',
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  d.description,
                                  style: const TextStyle(fontSize: 13, color: AppColors.navyDark, height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Variance: ${d.varianceQuantity.toInt()} ${d.materialUnit}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: d.varianceQuantity < 0 ? AppColors.redCritical : AppColors.amberWarning,
                                      ),
                                    ),
                                    Text(
                                      'Impact: ${Formatters.currency(d.financialImpactEtb)}',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.navyDark),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
      onSelected: (_) => setState(() => _selectedTab = code),
    );
  }
}
