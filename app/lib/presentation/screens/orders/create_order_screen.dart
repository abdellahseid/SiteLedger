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
      // Fetch available materials and suppliers from API
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
          const SnackBar(content: Text('✅ Purchase order created and submitted for PM approval!')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Purchase Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Project: ${selectedProj?.name ?? "Bole Lemi Industrial Park"}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _poNumberCtrl,
                      decoration: const InputDecoration(labelText: 'PO Number'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(labelText: 'Order Notes & Specifications'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Material Line Item',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Portland Pozzolana Cement (PPC 42.5R) — 50kg Bags',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Ordered Quantity (Bags)'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Unit Price (ETB)'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Builder(
                      builder: (ctx) {
                        final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
                        final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
                        return Text(
                          'Estimated Total: ${Formatters.currency(qty * price)}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.electricBlue),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create & Submit for Approval'),
            ),
          ],
        ),
      ),
    );
  }
}
