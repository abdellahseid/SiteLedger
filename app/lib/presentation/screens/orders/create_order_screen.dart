import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _poNumberCtrl = TextEditingController(text: 'PO-2026-BLIP-005');
  final _notesCtrl = TextEditingController(text: 'Reinforcement steel and cement for slab pouring');
  final _qtyCtrl = TextEditingController(text: '1000');
  final _priceCtrl = TextEditingController(text: '1350');

  bool _isSubmitting = false;

  @override
  void dispose() {
    _poNumberCtrl.dispose();
    _notesCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final selectedProj = ref.read(selectedProjectProvider);
    if (selectedProj == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a project.')));
      return;
    }

    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    if (qty <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid quantity and price.')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final materials = await ref.read(apiClientProvider).get('/api/materials');
      final suppliers = await ref.read(apiClientProvider).get('/api/materials/suppliers');

      final matList = materials['materials'] as List;
      final supList = suppliers['suppliers'] as List;

      final materialId = matList.isNotEmpty ? matList[0]['id'] : '';
      final supplierId = supList.isNotEmpty ? supList[0]['id'] : '';

      final payload = {
        'projectId': selectedProj.id,
        'supplierId': supplierId,
        'poNumber': _poNumberCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'lines': [
          {
            'materialId': materialId,
            'orderedQuantity': qty,
            'unitPriceEtb': price,
            'notes': 'Initial batch offloading',
          }
        ]
      };

      await ref.read(orderRepoProvider).createOrder(payload);
      ref.invalidate(ordersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emeraldSuccess,
            content: Text('✅ Purchase order created and submitted for PM approval!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating order: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedProj = ref.watch(selectedProjectProvider);
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final totalEtb = qty * price;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Purchase Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project Destination Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.electricBlue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.apartment_rounded, color: Color(0xFF38BDF8), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Destination Construction Site',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedProj?.name ?? "Bole Lemi Industrial Park (Phase II)",
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedProj?.code ?? 'BLIP',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF38BDF8)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Order Metadata Card
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
                      'Order Identification',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _poNumberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Order #',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Order Specifications & Notes',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Material Line Item & Live Pricing
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Material Line Item',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blueLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Standard Cement', style: TextStyle(color: AppColors.electricBlue, fontWeight: FontWeight.w700, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWarm,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.inventory_2_rounded, size: 20, color: AppColors.electricBlue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Portland Pozzolana Cement (PPC 42.5R) — 50kg Bags',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.navyDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity (Bags)',
                              prefixIcon: Icon(Icons.numbers_rounded),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Unit Price (ETB)',
                              prefixIcon: Icon(Icons.payments_outlined),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Estimated Total Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppGradients.sapphireGaze,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Estimated Total Order Value:',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                              ),
                            ],
                          ),
                          Text(
                            Formatters.currency(totalEtb),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create & Submit for PM Signoff', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
