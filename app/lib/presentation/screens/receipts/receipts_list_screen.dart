import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class ReceiptsListScreen extends ConsumerStatefulWidget {
  const ReceiptsListScreen({super.key});

  @override
  ConsumerState<ReceiptsListScreen> createState() => _ReceiptsListScreenState();
}

class _ReceiptsListScreenState extends ConsumerState<ReceiptsListScreen> {
  String _searchQuery = '';
  String _filterType = 'ALL';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Receipts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan Delivery QR',
            onPressed: () => context.push('/scan'),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Receive Delivery',
            onPressed: () => context.push('/receive'),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          onPressed: () => context.push('/receive'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Receive Delivery', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search waybill, truck plate, driver, or supplier...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _filterChip('ALL', 'All Receipts'),
                const SizedBox(width: 8),
                _filterChip('FLAGGED', 'With Variances / Defects'),
                const SizedBox(width: 8),
                _filterChip('VERIFIED', 'Verified Clean Deliveries'),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: receiptsAsync.when(
              data: (receipts) {
                final filtered = receipts.where((r) {
                  if (_filterType == 'FLAGGED' && r.status != 'FLAGGED') return false;
                  if (_filterType == 'VERIFIED' && r.status == 'FLAGGED') return false;

                  if (_searchQuery.isEmpty) return true;
                  return r.waybillNumber.toLowerCase().contains(_searchQuery) ||
                      r.truckLicensePlate.toLowerCase().contains(_searchQuery) ||
                      r.driverName.toLowerCase().contains(_searchQuery) ||
                      r.supplierName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Delivery Receipts Found',
                    message: _searchQuery.isEmpty
                        ? 'No material deliveries recorded matching your filters.'
                        : 'No deliveries matching "$_searchQuery".',
                    buttonLabel: 'Record New Delivery',
                    onButtonPressed: () => context.push('/receive'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(receiptsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final r = filtered[idx];
                      final isFlagged = r.status == 'FLAGGED';

                      return Card(
                        child: InkWell(
                          onTap: () => context.push('/receipts/${r.id}'),
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
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isFlagged ? AppColors.redBg : AppColors.blueLight,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            isFlagged ? Icons.report_problem_rounded : Icons.local_shipping_outlined,
                                            color: isFlagged ? AppColors.redCritical : AppColors.electricBlue,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          r.waybillNumber,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    StatusBadge(status: r.status),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'PO: ${r.poNumber} • ${r.supplierName}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.borderSubtle),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.badge_outlined, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: 5),
                                          Text(
                                            r.truckLicensePlate,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.person_outline, size: 15, color: AppColors.textMuted),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        r.driverName,
                                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 22),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                                        const SizedBox(width: 5),
                                        Text(
                                          Formatters.dateTime(r.deliveryTimestamp),
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        if (r.discrepancyCount > 0) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.redBg,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.redBorder),
                                            ),
                                            child: Text(
                                              '${r.discrepancyCount} Issue${r.discrepancyCount > 1 ? "s" : ""}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.redCritical),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.emeraldBg,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${Formatters.quantity(r.totalAcceptedQuantity, "")} accepted',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.emeraldDark),
                                          ),
                                        ),
                                      ],
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
              error: (err, _) => Center(child: Text('Error loading receipts: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String code, String label) {
    final isSelected = _filterType == code;
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
      onSelected: (_) => setState(() => _filterType = code),
    );
  }
}

