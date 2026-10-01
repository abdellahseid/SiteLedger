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
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final user = ref.watch(authProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan Order QR',
            onPressed: () => context.push('/scan'),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'New Order',
            onPressed: () => context.push('/orders/create'),
          ),
        ],
      ),
      floatingActionButton: (user?.isProcurement == true || user?.isProjectManager == true)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton.extended(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                elevation: 4,
                onPressed: () => context.push('/orders/create'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Order', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search PO number, supplier, or material...',
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

          // Modern Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

          const SizedBox(height: 6),

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
                        ? 'No purchase orders have been authorized yet for this project.'
                        : 'No orders found matching the "$_selectedFilter" filter.',
                    buttonLabel: 'Create Purchase Order',
                    onButtonPressed: () => context.push('/orders/create'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(ordersProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final po = filtered[idx];
                      return Card(
                        child: InkWell(
                          onTap: () => context.push('/orders/${po.id}'),
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
                                            color: AppColors.blueLight,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.description_outlined, color: AppColors.electricBlue, size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          po.poNumber,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15.5,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    StatusBadge(status: po.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: AppColors.surfaceMuted,
                                      child: Text(
                                        po.supplierName.isNotEmpty ? po.supplierName[0] : 'S',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        po.supplierName,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Total Value', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 2),
                                        Text(
                                          Formatters.currency(po.totalAmountEtb),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textMuted),
                                        const SizedBox(width: 5),
                                        Text(
                                          Formatters.date(po.createdAt),
                                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => setState(() => _selectedFilter = code),
    );
  }
}

