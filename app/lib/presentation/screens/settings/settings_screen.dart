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
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.blueLight,
                    child: Text(
                      user?.fullName.substring(0, 1) ?? 'U',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.electricBlue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyDark),
                        ),
                        Text(
                          '${user?.role.replaceAll("_", " ")} • ${user?.jobTitle ?? "Site Officer"}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Role Switcher for Evaluation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Role Switcher (Field & HQ Personas)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.navyDark),
                  ),
                  const SizedBox(height: 10),
                  _roleRadio(
                    ref,
                    title: 'Chala Lemma (Storekeeper)',
                    subtitle: 'Site receiving, tally inspection, outbox sync',
                    email: 'storekeeper@siteledger.et',
                    currentEmail: user?.email ?? '',
                  ),
                  _roleRadio(
                    ref,
                    title: 'Aster Bekele (Senior Project Manager)',
                    subtitle: 'PO approval sign-offs, dispute resolution, executive reports',
                    email: 'pm@siteledger.et',
                    currentEmail: user?.email ?? '',
                  ),
                  _roleRadio(
                    ref,
                    title: 'Dawit Tadesse (Procurement Officer)',
                    subtitle: 'PO creation, supplier contracting, credit note claims',
                    email: 'procurement@siteledger.et',
                    currentEmail: user?.email ?? '',
                  ),
                  _roleRadio(
                    ref,
                    title: 'Henok Girma (Supplier Logistics Rep)',
                    subtitle: 'Muger Cement & Habesha Steel dispatch tracking',
                    email: 'supplier@siteledger.et',
                    currentEmail: user?.email ?? '',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Preferences
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode (Site Low-Light)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('High contrast dark theme for nighttime & tunnel inspection', style: TextStyle(fontSize: 12)),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined, color: AppColors.electricBlue),
                  title: const Text('Offline Sync Center', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Manage Drift SQLite outbox & manual sync triggers', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/sync'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.network_check_outlined, color: AppColors.emeraldSuccess),
                  title: const Text('Backend API Gateway', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(ref.watch(apiClientProvider).baseUrl, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.redCritical),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _roleRadio(
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required String email,
    required String currentEmail,
  }) {
    final isSelected = currentEmail.toLowerCase() == email.toLowerCase();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<String>(
        value: email,
        groupValue: currentEmail,
        activeColor: AppColors.electricBlue,
        onChanged: (val) {
          if (val != null) ref.read(authProvider.notifier).switchRole(val);
        },
      ),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, fontSize: 13.5)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5)),
      onTap: () => ref.read(authProvider.notifier).switchRole(email),
    );
  }
}
