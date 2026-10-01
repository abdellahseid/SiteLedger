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

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  final _codeCtrl = TextEditingController(text: 'PO-2026-BLIP-001');
  bool _isSearching = false;

  @override
  void dispose() {
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
            SnackBar(content: Text('Order ${po.poNumber} is in status ${po.status} (Needs PM Approval first)')),
          );
        } else {
          context.pushReplacement('/receive', extra: po);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order not found for QR: $poNumber')),
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
        title: const Text('Scan Order QR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanner Viewport Mockup
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.navyDark,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Viewfinder Crosshairs
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.electricBlue, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 96,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Align site purchase order QR code',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Manual Entry Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manual PO Lookup',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _codeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'PO Number / Barcode',
                              prefixIcon: Icon(Icons.qr_code_2_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isSearching ? null : () => _lookupPo(_codeCtrl.text),
                          child: _isSearching
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Lookup'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Demo Buttons
            const Text(
              'Demo Preset Orders (Instant Scan Test)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),

            _demoButton('PO-2026-BLIP-001', 'Muger Cement • 2,000 Bags • Partially Received'),
            const SizedBox(height: 8),
            _demoButton('PO-2026-BLIP-002', 'Habesha Steel Mills • 30 Tonnes Rebar • Approved'),
            const SizedBox(height: 8),
            _demoButton('PO-2026-MSTI-003', 'Derba MIDROC • 600 m³ Aggregates • Pending Approval'),
          ],
        ),
      ),
    );
  }

  Widget _demoButton(String poNumber, String subtitle) {
    return Card(
      child: ListTile(
        onTap: () {
          _codeCtrl.text = poNumber;
          _lookupPo(poNumber);
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.qr_code_rounded, color: AppColors.electricBlue, size: 20),
        ),
        title: Text(poNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.navyDark)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }
}
