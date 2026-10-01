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

  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Receipts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Receive New Delivery',
            onPressed: () => context.push('/scan'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/receive'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Receive Delivery'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by waybill, plate, driver, or supplier...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: receiptsAsync.when(
              data: (receipts) {
                final filtered = receipts.where((r) {
                  if (_searchQuery.isEmpty) return true;
                  return r.waybillNumber.toLowerCase().contains(_searchQuery) ||
                      r.truckLicensePlate.toLowerCase().contains(_searchQuery) ||
                      r.driverName.toLowerCase().contains(_searchQuery) ||
                      r.supplierName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Delivery Receipts',
                    message: 'No material deliveries recorded matching your search.',
                    buttonLabel: 'Record New Delivery',
                    onButtonPressed: () => context.push('/receive'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(receiptsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final r = filtered[idx];
                      return Card(
                        child: InkWell(
                          onTap: () => context.push('/receipts/${r.id}'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      r.waybillNumber,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyDark),
                                    ),
                                    StatusBadge(status: r.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'PO: ${r.poNumber} • ${r.supplierName}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Truck: ${r.truckLicensePlate}',
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.navyDark),
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(Icons.person_outline, size: 16, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      r.driverName,
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Formatters.dateTime(r.deliveryTimestamp),
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                    ),
                                    Row(
                                      children: [
                                        if (r.discrepancyCount > 0) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.redBg,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${r.discrepancyCount} Issue${r.discrepancyCount > 1 ? "s" : ""}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.redCritical),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          '${Formatters.quantity(r.totalAcceptedQuantity, "")} accepted',
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.emeraldSuccess),
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
}
