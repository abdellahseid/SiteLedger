import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/order_model.dart';
import '../providers/app_providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/orders/orders_list_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/orders/create_order_screen.dart';
import '../screens/receiving/qr_scan_screen.dart';
import '../screens/receiving/receive_material_screen.dart';
import '../screens/receipts/receipts_list_screen.dart';
import '../screens/receipts/receipt_detail_screen.dart';
import '../screens/discrepancies/discrepancies_list_screen.dart';
import '../screens/discrepancies/discrepancy_detail_screen.dart';
import '../screens/sync/sync_center_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersListScreen(),
          ),
          GoRoute(
            path: '/receipts',
            builder: (context, state) => const ReceiptsListScreen(),
          ),
          GoRoute(
            path: '/issues',
            builder: (context, state) => const DiscrepanciesListScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/orders/create',
        builder: (context, state) => const CreateOrderScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const QrScanScreen(),
      ),
      GoRoute(
        path: '/receive',
        builder: (context, state) => ReceiveMaterialScreen(
          initialOrder: state.extra as PurchaseOrderModel?,
        ),
      ),
      GoRoute(
        path: '/receipts/:id',
        builder: (context, state) => ReceiptDetailScreen(receiptId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/issues/:id',
        builder: (context, state) => DiscrepancyDetailScreen(discrepancyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => const SyncCenterScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const _ScaffoldWithNavBar({required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/receipts')) return 3;
    if (location.startsWith('/issues')) return 4;
    return 0; // Overview (Dashboard)
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/orders');
        break;
      case 2:
        _showQuickIntakeSheet(context);
        break;
      case 3:
        context.go('/receipts');
        break;
      case 4:
        context.go('/issues');
        break;
    }
  }

  void _showQuickIntakeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: AppShadows.elevatedShadow,
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Site Delivery & Intake Hub',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Fast gate receiving & verification actions',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ActionTile(
                icon: Icons.qr_code_scanner_rounded,
                iconColor: AppColors.electricBlue,
                title: 'Scan Purchase Order QR',
                subtitle: 'Camera scan PO barcode or gate pass',
                badgeText: 'FASTEST',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/scan');
                },
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.edit_note_rounded,
                iconColor: AppColors.emeraldSuccess,
                title: 'Record Material Delivery Note',
                subtitle: 'Manual offload tally, photos, & driver info',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/receive');
                },
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.add_circle_outline_rounded,
                iconColor: AppColors.amberWarning,
                title: 'Create New Purchase Order',
                subtitle: 'Authorize new material procurement line items',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/orders/create');
                },
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.auto_awesome_rounded,
                iconColor: AppColors.purpleAi,
                title: 'Gemini Natural Language Queries',
                subtitle: 'Ask AI across project intake & supplier performance',
                badgeText: 'AI INTEL',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/reports');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;
    final discrepanciesAsync = ref.watch(discrepanciesProvider);
    final openIssuesCount = discrepanciesAsync.value?.where((d) => d.isOpen).length ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          height: 68,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface.withOpacity(0.95) : Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.borderSubtle.withOpacity(0.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(isDark ? 0.35 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Overview',
                isSelected: selectedIndex == 0,
                onTap: () => _onItemTapped(0, context),
              ),
              _NavBarItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
                label: 'Orders',
                isSelected: selectedIndex == 1,
                onTap: () => _onItemTapped(1, context),
              ),
              // Center Floating Action Button
              GestureDetector(
                onTap: () => _onItemTapped(2, context),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.primaryGlow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              _NavBarItem(
                icon: Icons.local_shipping_outlined,
                activeIcon: Icons.local_shipping_rounded,
                label: 'Receipts',
                badgeCount: pendingCount,
                badgeColor: AppColors.amberWarning,
                isSelected: selectedIndex == 3,
                onTap: () => _onItemTapped(3, context),
              ),
              _NavBarItem(
                icon: Icons.warning_amber_rounded,
                activeIcon: Icons.warning_rounded,
                label: 'Issues',
                badgeCount: openIssuesCount,
                badgeColor: AppColors.redCritical,
                isSelected: selectedIndex == 4,
                onTap: () => _onItemTapped(4, context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final Color badgeColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    this.badgeCount,
    this.badgeColor = AppColors.electricBlue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? AppColors.electricBlue
        : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.electricBlue.withOpacity(0.15) : AppColors.blueLight)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: color,
                  size: 22,
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -7,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badgeText;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceWarm,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText!,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: iconColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

