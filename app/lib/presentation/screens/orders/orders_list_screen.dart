import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan Order QR',
            onPressed: () => context.push('/scan'),
          ),
        ],
      ),
      floatingActionButton: (user?.isProcurement == true || user?.isProjectManager == true)
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/orders/create'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Order'),
            )
          : null,
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filterChip('ALL', 'All Orders'),
                const SizedBox(width: 8),
                _filterChip('APPROVED', 'Approved'),
                const SizedBox(width: 8),
                _filterChip('PENDING_APPROVAL', 'Pending'),
                const SizedBox(width: 8),
                _filterChip('PARTIALLY_RECEIVED', 'Partially Received'),
                const SizedBox(width: 8),
                _filterChip('COMPLETED', 'Completed'),
              ],
            ),
          ),

          // Orders Feed
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filtered = orders.where((o) {
                  if (_selectedFilter != 'ALL' && o.status != _selectedFilter) return false;
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    return o.poNumber.toLowerCase().contains(q) ||
                        o.supplierName.toLowerCase().contains(q);
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'No Purchase Orders Found',
                    message: _selectedFilter == 'ALL'
                        ? 'No purchase orders have been created yet for this project.'
                        : 'No orders found matching the "$_selectedFilter" filter.',
                    buttonLabel: 'Create Purchase Order',
                    onButtonPressed: () => context.push('/orders/create'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(ordersProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final po = filtered[idx];
                      return Card(
                        child: InkWell(
                          onTap: () => context.push('/orders/${po.id}'),
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
                                      po.poNumber,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyDark),
                                    ),
                                    StatusBadge(status: po.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.storefront_outlined, size: 16, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      po.supplierName,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Formatters.currency(po.totalAmountEtb),
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.navyDark),
                                    ),
                                    Text(
                                      Formatters.date(po.createdAt),
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
              error: (err, _) => Center(child: Text('Error loading orders: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String code, String label) {
    final isSelected = _selectedFilter == code;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.navyDark,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.navyDark,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _selectedFilter = code),
    );
  }
}
