import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/offline_sync_banner.dart';
import '../../widgets/material_progress_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final projectsAsync = ref.watch(projectsProvider);
    final selectedProj = ref.watch(selectedProjectProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.organizationName ?? 'Abyssinia Infrastructures PLC',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.electricBlue),
            ),
            Row(
              children: [
                Text(
                  selectedProj?.name ?? 'Bole Lemi Industrial Park',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.navyDark),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync Center',
            onPressed: () => context.push('/sync'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Reports & AI',
            onPressed: () => context.push('/reports'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardMetricsProvider);
          ref.invalidate(projectsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const OfflineSyncBanner(),

            // Project Selector Bar
            projectsAsync.when(
              data: (projects) {
                if (projects.length <= 1) return const SizedBox.shrink();
                return Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: projects.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final p = projects[idx];
                      final isSelected = selectedProj?.id == p.id;
                      return ChoiceChip(
                        label: Text(p.code),
                        selected: isSelected,
                        selectedColor: AppColors.navyDark,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.navyDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (_) {
                          ref.read(selectedProjectProvider.notifier).state = p;
                          ref.invalidate(dashboardMetricsProvider);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Top KPI Grid
            metricsAsync.when(
              data: (data) {
                final orders = data['orders'] ?? {};
                final deliveries = data['deliveries'] ?? {};
                final discrepancies = data['discrepancies'] ?? {};

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Deliveries Intake',
                              value: deliveries['total_deliveries']?.toString() ?? '1',
                              subtitle: '${deliveries['flagged_deliveries'] ?? 1} flagged',
                              icon: Icons.local_shipping_rounded,
                              iconColor: AppColors.electricBlue,
                              onTap: () => context.go('/receipts'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: 'Active Orders',
                              value: orders['total_orders']?.toString() ?? '4',
                              subtitle: '${orders['active_orders'] ?? 2} approved',
                              icon: Icons.description_rounded,
                              iconColor: AppColors.emeraldSuccess,
                              onTap: () => context.go('/orders'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Open Issues',
                              value: discrepancies['open_discrepancies']?.toString() ?? '2',
                              subtitle: 'Shortage & Damage',
                              icon: Icons.warning_amber_rounded,
                              iconColor: AppColors.redCritical,
                              onTap: () => context.go('/issues'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: 'Exposure at Risk',
                              value: Formatters.currency(num.tryParse(discrepancies['at_risk_etb']?.toString() ?? '108000') ?? 108000, compact: true),
                              subtitle: 'Pending reconciliation',
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: AppColors.amberWarning,
                              onTap: () => context.go('/issues'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 12),

            // Fast Receiving Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: AppColors.navyDark,
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
                              color: AppColors.electricBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Material Delivery Receiving',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                                Text(
                                  'Scan purchase order QR or enter waybill note',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.electricBlue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => context.push('/scan'),
                              icon: const Icon(Icons.qr_code_rounded, size: 18),
                              label: const Text('Scan Order QR'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF334155)),
                              ),
                              onPressed: () => context.push('/receive'),
                              icon: const Icon(Icons.edit_note_rounded, size: 18),
                              label: const Text('Manual Entry'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Material Intake Fulfillment Progress
            metricsAsync.when(
              data: (data) {
                final materials = data['materials'] as List? ?? [];
                if (materials.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Material Intake Progress',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                              ),
                              Icon(Icons.inventory_2_outlined, color: AppColors.electricBlue, size: 18),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...materials.take(4).map((m) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.navyDark),
                                  ),
                                  const SizedBox(height: 6),
                                  MaterialProgressBar(
                                    ordered: num.tryParse(m['total_ordered']?.toString() ?? '0')?.toDouble() ?? 0.0,
                                    accepted: num.tryParse(m['total_accepted']?.toString() ?? '0')?.toDouble() ?? 0.0,
                                    unit: m['unit'] ?? '',
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Recent Deliveries Feed
            metricsAsync.when(
              data: (data) {
                final recents = data['recentDeliveries'] as List? ?? [];
                if (recents.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Site Deliveries',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                          ),
                          TextButton(
                            onPressed: () => context.go('/receipts'),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      ...recents.map((r) {
                        final isFlagged = r['status'] == 'FLAGGED';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            onTap: () => context.push('/receipts/${r['id']}'),
                            leading: CircleAvatar(
                              backgroundColor: isFlagged ? AppColors.redBg : AppColors.blueLight,
                              child: Icon(
                                isFlagged ? Icons.report_problem_rounded : Icons.local_shipping_outlined,
                                color: isFlagged ? AppColors.redCritical : AppColors.electricBlue,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              r['waybill_number'] ?? r['receipt_number'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.navyDark),
                            ),
                            subtitle: Text(
                              '${r['supplier_name']} • Truck: ${r['truck_license_plate']}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            trailing: StatusBadge(status: r['status'] ?? 'SUBMITTED', isSmall: true),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
