import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> with SingleTickerProviderStateMixin {
  final _codeCtrl = TextEditingController(text: 'PO-2026-BLIP-001');
  bool _isSearching = false;
  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _lookupPo(String poNumber) async {
    if (poNumber.trim().isEmpty) return;
    setState(() => _isSearching = true);

    try {
      final po = await ref.read(orderRepoProvider).getOrderByNumber(poNumber.trim());
      if (mounted) {
        if (!po.canReceive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.amberWarning,
              content: Text('Order ${po.poNumber} is in status ${po.status} (Needs PM Approval before site intake)'),
            ),
          );
        } else {
          context.pushReplacement('/receive', extra: po);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.redCritical,
            content: Text('Order not found for QR: $poNumber'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Order Barcode / QR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanner Viewport Mockup with Animated Laser Line
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.electricBlue.withOpacity(0.3)),
                boxShadow: AppShadows.cardHover,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Viewfinder Box with Glowing Corner Reticles
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.electricBlue.withOpacity(0.4), width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        // Center Barcode Icon
                        Center(
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 100,
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        // Animated Scanning Laser Bar
                        AnimatedBuilder(
                          animation: _laserController,
                          builder: (context, child) {
                            return Positioned(
                              top: 20 + (_laserController.value * 160),
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.transparent, Color(0xFF38BDF8), Colors.transparent],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF38BDF8).withOpacity(0.8),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bottom Guidance Pill
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.center_focus_strong_rounded, size: 14, color: Color(0xFF38BDF8)),
                          SizedBox(width: 8),
                          Text(
                            'Align site purchase order QR code',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Manual Entry Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: AppShadows.subtle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manual PO Number Lookup',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _codeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'PO Number / Barcode',
                              hintText: 'PO-2026-BLIP-001',
                              prefixIcon: Icon(Icons.qr_code_2_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isSearching ? null : () => _lookupPo(_codeCtrl.text),
                          child: _isSearching
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Lookup', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Demo Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Demo Preset Orders (Instant Scan)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('1-Tap Test', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emeraldSuccess)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _demoButton(
              'PO-2026-BLIP-001',
              'Muger Cement • 2,000 Bags • Partially Received',
              status: 'READY',
              statusColor: AppColors.emeraldSuccess,
            ),
            const SizedBox(height: 8),
            _demoButton(
              'PO-2026-BLIP-002',
              'Habesha Steel Mills • 30 Tonnes Rebar • Approved',
              status: 'APPROVED',
              statusColor: AppColors.electricBlue,
            ),
            const SizedBox(height: 8),
            _demoButton(
              'PO-2026-MSTI-003',
              'Derba MIDROC • 600 m³ Aggregates • Pending PM',
              status: 'PENDING',
              statusColor: AppColors.amberWarning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoButton(
    String poNumber,
    String subtitle, {
    required String status,
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.subtle,
      ),
      child: ListTile(
        onTap: () {
          _codeCtrl.text = poNumber;
          _lookupPo(poNumber);
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.electricBlue, size: 20),
        ),
        title: Text(poNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.navyDark)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: statusColor),
          ),
        ),
      ),
    );
  }
}
