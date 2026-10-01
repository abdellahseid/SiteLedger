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
  final authState = ref.watch(authProvider);

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
    if (location.startsWith('/receipts')) return 2;
    if (location.startsWith('/issues')) return 3;
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
        context.go('/receipts');
        break;
      case 3:
        context.go('/issues');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (idx) => _onItemTapped(idx, context),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Overview',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.local_shipping_outlined),
                if (pendingCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.amberWarning,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.local_shipping_rounded),
            label: 'Receipts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            activeIcon: Icon(Icons.warning_rounded),
            label: 'Issues',
          ),
        ],
      ),
    );
  }
}
