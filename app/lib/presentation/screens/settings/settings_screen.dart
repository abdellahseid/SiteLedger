import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          // Profile Hero Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.electricBlue.withOpacity(0.2)),
              boxShadow: AppShadows.cardHover,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user?.fullName.substring(0, 1) ?? 'U',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Authorized User',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.electricBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${user?.role.replaceAll("_", " ")} • ${user?.jobTitle ?? "Site Officer"}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Role Switcher for Evaluation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enterprise Role Personas',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Evaluation Switcher', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _personaCard(
            ref,
            title: 'Chala Lemma (Storekeeper)',
            role: 'FIELD STOREKEEPER',
            subtitle: 'Offline intake verification, truck tally, drift outbox synchronization',
            email: 'storekeeper@siteledger.et',
            currentEmail: user?.email ?? '',
            avatarColor: AppColors.emeraldSuccess,
            icon: Icons.inventory_2_rounded,
          ),
          _personaCard(
            ref,
            title: 'Aster Bekele (Senior Project Manager)',
            role: 'PROJECT MANAGER',
            subtitle: 'PO approvals, commercial dispute resolution, contractual FIDIC claims',
            email: 'pm@siteledger.et',
            currentEmail: user?.email ?? '',
            avatarColor: AppColors.electricBlue,
            icon: Icons.assignment_turned_in_rounded,
          ),
          _personaCard(
            ref,
            title: 'Dawit Tadesse (Procurement Officer)',
            role: 'PROCUREMENT',
            subtitle: 'Supplier contracts, PO issuance, ledger valuation reconciliation',
            email: 'procurement@siteledger.et',
            currentEmail: user?.email ?? '',
            avatarColor: AppColors.amberWarning,
            icon: Icons.shopping_cart_rounded,
          ),
          _personaCard(
            ref,
            title: 'Henok Girma (Supplier Logistics Rep)',
            role: 'SUPPLIER REP',
            subtitle: 'Dispatch notifications, truck waybill matching & electronic delivery notes',
            email: 'supplier@siteledger.et',
            currentEmail: user?.email ?? '',
            avatarColor: const Color(0xFF64748B),
            icon: Icons.local_shipping_rounded,
          ),

          const SizedBox(height: 24),

          // App Preferences
          const Text(
            'System & Connectivity',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyDark),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: const Text('Dark Mode (Site Low-Light)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('High contrast dark theme for nighttime & tunnel inspection', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  value: themeMode == ThemeMode.dark,
                  activeColor: AppColors.electricBlue,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.blueLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.cloud_sync_rounded, color: AppColors.electricBlue, size: 20),
                  ),
                  title: const Text('Offline Sync Center', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Manage Drift SQLite outbox & manual sync triggers', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () => context.push('/sync'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.hub_rounded, color: AppColors.emeraldSuccess, size: 20),
                  ),
                  title: const Text('Backend API Gateway', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text(
                    ref.watch(apiClientProvider).baseUrl,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.redCritical,
              side: const BorderSide(color: AppColors.redCritical, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out of Active Session', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _personaCard(
    WidgetRef ref, {
    required String title,
    required String role,
    required String subtitle,
    required String email,
    required String currentEmail,
    required Color avatarColor,
    required IconData icon,
  }) {
    final isSelected = currentEmail.toLowerCase() == email.toLowerCase();

    return InkWell(
      onTap: () => ref.read(authProvider.notifier).switchRole(email),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueLight.withOpacity(0.4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.electricBlue : AppColors.borderSubtle,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected ? AppShadows.subtle : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: avatarColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: avatarColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                            fontSize: 13.5,
                            color: AppColors.navyDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.electricBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              )
            else
              const Icon(Icons.radio_button_unchecked_rounded, size: 18, color: AppColors.borderDark),
          ],
        ),
      ),
    );
  }
}
