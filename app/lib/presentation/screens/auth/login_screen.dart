import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'storekeeper@siteledger.et');
  final _passCtrl = TextEditingController(text: 'Password123!');
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    await ref.read(authProvider.notifier).login(email, password);
    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.go('/');
    }
  }

  void _quickSwitch(String email) async {
    _emailCtrl.text = email;
    await ref.read(authProvider.notifier).login(email, 'Password123!');
    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.navyDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'SiteLedger',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navyDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Ethiopia Construction Intelligence',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.electricBlue),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Welcome Heading
                  const Text(
                    'Material Delivery Verification',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Offline-first intake control for project managers, storekeepers & suppliers',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Login Inputs
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Work Email',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    child: authState.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Sign In to Project'),
                  ),
                  const SizedBox(height: 36),

                  // Quick Role Demo Switcher
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.bolt, color: AppColors.amberWarning, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Instant Role Switcher (Demo)',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DemoUserTile(
                          role: 'STOREKEEPER',
                          name: 'Chala Lemma',
                          email: 'storekeeper@siteledger.et',
                          badgeColor: AppColors.emeraldSuccess,
                          onTap: () => _quickSwitch('storekeeper@siteledger.et'),
                        ),
                        _DemoUserTile(
                          role: 'PROJECT MANAGER',
                          name: 'Aster Bekele',
                          email: 'pm@siteledger.et',
                          badgeColor: AppColors.electricBlue,
                          onTap: () => _quickSwitch('pm@siteledger.et'),
                        ),
                        _DemoUserTile(
                          role: 'PROCUREMENT',
                          name: 'Dawit Tadesse',
                          email: 'procurement@siteledger.et',
                          badgeColor: AppColors.amberWarning,
                          onTap: () => _quickSwitch('procurement@siteledger.et'),
                        ),
                        _DemoUserTile(
                          role: 'SUPPLIER',
                          name: 'Henok Girma',
                          email: 'supplier@siteledger.et',
                          badgeColor: Color(0xFF64748B),
                          onTap: () => _quickSwitch('supplier@siteledger.et'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoUserTile extends StatelessWidget {
  final String role;
  final String name;
  final String email;
  final Color badgeColor;
  final VoidCallback onTap;

  const _DemoUserTile({
    required this.role,
    required this.name,
    required this.email,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: badgeColor.withOpacity(0.15),
              child: Text(
                name.substring(0, 1),
                style: TextStyle(color: badgeColor, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.navyDark)),
                  Text(email, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                role,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
