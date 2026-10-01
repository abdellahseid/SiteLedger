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
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.emeraldSuccess,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user?.organizationName ?? 'Abyssinia Infrastructures PLC',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricBlue,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: () => _showProjectSelector(context, ref),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedProj?.name ?? 'Bole Lemi Industrial Park',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.navyDark,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.sync_rounded),
                tooltip: 'Offline Sync Center',
                onPressed: () => context.push('/sync'),
              ),
              if (pendingCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.amberWarning,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Gemini AI & Reports',
            onPressed: () => context.push('/reports'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Settings & Personas',
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardMetricsProvider);
          ref.invalidate(projectsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            const OfflineSyncBanner(),

            // Hero Project Card with Gradient Mesh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.heroCardGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.apartment_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                selectedProj?.code ?? 'BLIP-01',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldSuccess.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.emeraldSuccess.withOpacity(0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.wifi_rounded, color: AppColors.emeraldSuccess, size: 13),
                              SizedBox(width: 5),
                              Text(
                                'OFFLINE READY',
                                style: TextStyle(
                                  color: AppColors.emeraldSuccess,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      selectedProj?.name ?? 'Bole Lemi Industrial Park (Phase 2)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Client: Industrial Parks Development Corp (IPDC) • General Contractor: Abyssinia SC',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => context.push('/scan'),
                            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                            label: const Text('Scan Delivery QR', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => context.push('/receive'),
                            icon: const Icon(Icons.edit_note_rounded, size: 18),
                            label: const Text('Manual Intake', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Top KPI Metrics
            metricsAsync.when(
              data: (data) {
                final orders = data['orders'] ?? {};
                final deliveries = data['deliveries'] ?? {};
                final discrepancies = data['discrepancies'] ?? {};

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Deliveries Intake',
                              value: deliveries['total_deliveries']?.toString() ?? '1',
                              subtitle: '${deliveries['flagged_deliveries'] ?? 1} flagged for review',
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
                              subtitle: '${orders['active_orders'] ?? 2} authorized POs',
                              icon: Icons.assignment_rounded,
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
                              title: 'Open Variances',
                              value: discrepancies['open_discrepancies']?.toString() ?? '2',
                              subtitle: 'Shortage & moisture',
                              icon: Icons.warning_amber_rounded,
                              iconColor: AppColors.redCritical,
                              onTap: () => context.go('/issues'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: 'Exposure at Risk',
                              value: Formatters.currency(
                                num.tryParse(discrepancies['at_risk_etb']?.toString() ?? '108000') ?? 108000,
                                compact: true,
                              ),
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
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Quick Hub Navigation Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _QuickNavCard(
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.purpleAi,
                    title: 'Gemini AI',
                    subtitle: 'Audit Queries',
                    onTap: () => context.push('/reports'),
                  ),
                  const SizedBox(width: 10),
                  _QuickNavCard(
                    icon: Icons.cloud_sync_outlined,
                    color: AppColors.amberWarning,
                    title: 'Sync Outbox',
                    subtitle: '$pendingCount Queued',
                    onTap: () => context.push('/sync'),
                  ),
                  const SizedBox(width: 10),
                  _QuickNavCard(
                    icon: Icons.add_circle_outline_rounded,
                    color: AppColors.emeraldSuccess,
                    title: 'New Order',
                    subtitle: 'Procurement',
                    onTap: () => context.push('/orders/create'),
                  ),
                ],
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Material Intake Fulfillment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Target vs verified physical offload',
                                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.blueLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.inventory_2_outlined, color: AppColors.electricBlue, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          ...materials.take(4).map((m) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        m['name'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                        ),
                                      ),
                                    ],
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
                          Text(
                            'Recent Site Deliveries',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/receipts'),
                            child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...recents.map((r) {
                        final isFlagged = r['status'] == 'FLAGGED';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () => context.push('/receipts/${r['id']}'),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isFlagged ? AppColors.redBg : AppColors.blueLight,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      isFlagged ? Icons.report_problem_rounded : Icons.local_shipping_outlined,
                                      color: isFlagged ? AppColors.redCritical : AppColors.electricBlue,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              r['waybill_number'] ?? r['receipt_number'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14.5,
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${r['supplier_name']} • Truck: ${r['truck_license_plate']}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(status: r['status'] ?? 'SUBMITTED', isSmall: true),
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
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectSelector(BuildContext context, WidgetRef ref) {
    final projects = ref.read(projectsProvider).value ?? [];
    if (projects.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final selectedProj = ref.watch(selectedProjectProvider);
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Switch Active Project',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ...projects.map((p) {
                final isSelected = p.id == selectedProj?.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.electricBlue.withOpacity(0.15) : AppColors.blueLight)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.electricBlue : (isDark ? AppColors.darkBorder : AppColors.borderSubtle),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.electricBlue : AppColors.borderSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.apartment_rounded,
                        color: isSelected ? Colors.white : AppColors.navyDark,
                        size: 18,
                      ),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text('${p.code} • ${p.location}', style: const TextStyle(fontSize: 12)),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.electricBlue) : null,
                    onTap: () {
                      ref.read(selectedProjectProvider.notifier).state = p;
                      ref.invalidate(dashboardMetricsProvider);
                      ref.invalidate(ordersProvider);
                      ref.invalidate(receiptsProvider);
                      ref.invalidate(discrepanciesProvider);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _QuickNavCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickNavCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

