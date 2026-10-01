import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';
import '../../providers/app_providers.dart';

class ReceiveMaterialScreen extends ConsumerStatefulWidget {
  final PurchaseOrderModel? initialOrder;

  const ReceiveMaterialScreen({super.key, this.initialOrder});

  @override
  ConsumerState<ReceiveMaterialScreen> createState() => _ReceiveMaterialScreenState();
}

class _ReceiveMaterialScreenState extends ConsumerState<ReceiveMaterialScreen> {
  PurchaseOrderModel? _selectedPo;
  
  // Step 1: Logistics Fields
  final _waybillCtrl = TextEditingController(text: 'WB-MUG-91024');
  final _truckPlateCtrl = TextEditingController(text: 'ET-3-77219-AA');
  final _driverNameCtrl = TextEditingController(text: 'Abebe Bikila');
  final _carrierCtrl = TextEditingController(text: 'Trans-Ethiopia Freight SC');
  final _notesCtrl = TextEditingController(text: 'Dispatched from factory at 06:30 AM. Arrived at Site Gate 4.');

  // Step 2: Line quantities
  double _orderedQty = 1000.0;
  double _deliveredQty = 960.0; // 40 shortage
  double _acceptedQty = 930.0;  // 30 damaged
  double _damagedQty = 30.0;
  double _rejectedQty = 30.0;
  final _rejectionReasonCtrl = TextEditingController(text: 'Moisture ingress on 30 sacks. Partial hardening.');

  // Step 3: Photos attached
  bool _attachedWaybill = true;
  bool _attachedTruckPlate = true;
  bool _attachedDamagePhoto = true;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrder != null) {
      _selectedPo = widget.initialOrder;
      if (_selectedPo!.lines.isNotEmpty) {
        final line = _selectedPo!.lines.first;
        _orderedQty = line.orderedQuantity;
        _deliveredQty = line.orderedQuantity;
        _acceptedQty = line.orderedQuantity;
        _damagedQty = 0;
        _rejectedQty = 0;
      }
    }
  }

  @override
  void dispose() {
    _waybillCtrl.dispose();
    _truckPlateCtrl.dispose();
    _driverNameCtrl.dispose();
    _carrierCtrl.dispose();
    _notesCtrl.dispose();
    _rejectionReasonCtrl.dispose();
    super.dispose();
  }

  void _recalcQuantities() {
    setState(() {
      _acceptedQty = (_deliveredQty - _rejectedQty).clamp(0.0, _deliveredQty);
    });
  }

  void _handleSubmit() async {
    if (_selectedPo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a purchase order.')));
      return;
    }
    if (_waybillCtrl.text.trim().isEmpty || _truckPlateCtrl.text.trim().isEmpty || _driverNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete Waybill, Truck Plate, and Driver name.')));
      return;
    }

    setState(() => _isSubmitting = true);
    final idempotencyKey = const Uuid().v4();
    final receiptNumber = 'REC-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final line = _selectedPo!.lines.isNotEmpty ? _selectedPo!.lines.first : null;
    final polId = line?.id ?? 'pol-demo';
    final matId = line?.materialId ?? 'mat-demo';
    final unit = line?.unit ?? 'Bags';

    final payload = {
      'projectId': _selectedPo!.projectId,
      'purchaseOrderId': _selectedPo!.id,
      'receiptNumber': receiptNumber,
      'waybillNumber': _waybillCtrl.text.trim(),
      'truckLicensePlate': _truckPlateCtrl.text.trim(),
      'driverName': _driverNameCtrl.text.trim(),
      'carrierName': _carrierCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'idempotencyKey': idempotencyKey,
      'latitude': 9.01234,
      'longitude': 38.76543,
      'lines': [
        {
          'purchaseOrderLineId': polId,
          'materialId': matId,
          'orderedQuantity': _orderedQty,
          'deliveredQuantity': _deliveredQty,
          'acceptedQuantity': _acceptedQty,
          'damagedQuantity': _damagedQty,
          'rejectedQuantity': _rejectedQty,
          'rejectionReason': _rejectedQty > 0 ? _rejectionReasonCtrl.text.trim() : null,
          'unit': unit,
        }
      ]
    };

    try {
      final res = await ref.read(receiptRepoProvider).createReceipt(payload);

      // Refresh providers
      ref.invalidate(receiptsProvider);
      ref.invalidate(ordersProvider);
      ref.invalidate(discrepanciesProvider);
      ref.invalidate(dashboardMetricsProvider);

      if (mounted) {
        if (res.isOfflineQueued) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.amberWarning,
              content: Text('📱 Offline mode: Receipt saved to Drift SQLite outbox. Will auto-sync when online!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.emeraldSuccess,
              content: Text('✅ Material delivery verified and recorded successfully!'),
            ),
          );
        }
        context.go('/receipts');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receiving error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Receiving'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Select Purchase Order Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '1. Purchase Order Match',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/scan'),
                          icon: const Icon(Icons.qr_code_scanner, size: 16),
                          label: const Text('Scan QR'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ordersAsync.when(
                      data: (orders) {
                        final validOrders = orders.where((o) => o.canReceive).toList();
                        if (validOrders.isEmpty) {
                          return const Text('No approved purchase orders available for receiving.', style: TextStyle(color: AppColors.redCritical));
                        }

                        if (_selectedPo == null && validOrders.isNotEmpty) {
                          _selectedPo = validOrders.first;
                        }

                        return DropdownButtonFormField<PurchaseOrderModel>(
                          value: _selectedPo,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Select Order'),
                          items: validOrders.map((o) {
                            return DropdownMenuItem(
                              value: o,
                              child: Text('${o.poNumber} — ${o.supplierName}', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPo = val;
                              if (val != null && val.lines.isNotEmpty) {
                                final l = val.lines.first;
                                _orderedQty = l.orderedQuantity;
                                _deliveredQty = l.orderedQuantity;
                                _acceptedQty = l.orderedQuantity;
                                _damagedQty = 0;
                                _rejectedQty = 0;
                              }
                            });
                          },
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Could not load orders'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Step 2: Logistics & Carrier Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. Waybill & Transport Verification',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _waybillCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Supplier Waybill / Delivery Note #',
                        prefixIcon: Icon(Icons.receipt_long_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _truckPlateCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Truck License Plate',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _driverNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Driver Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carrierCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Logistics Carrier / Transporter',
                        prefixIcon: Icon(Icons.local_shipping_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Step 3: Material Quantity Tally & Defect Detection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '3. Material Intake Tally',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blueLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Gate 4 Scale', style: TextStyle(color: AppColors.electricBlue, fontWeight: FontWeight.w700, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Ordered Qty (Readonly target)
                    _tallyTile(
                      label: 'Ordered on PO',
                      value: '$_orderedQty Bags',
                      color: AppColors.navyDark,
                      icon: Icons.checklist_rounded,
                    ),
                    const SizedBox(height: 10),

                    // Delivered Qty Input
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: const Text('Total Delivered on Truck:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: _deliveredQty.toInt().toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(suffixText: 'Bags'),
                            onChanged: (val) {
                              _deliveredQty = double.tryParse(val) ?? 0;
                              _recalcQuantities();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Damaged / Rejected Qty Input
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: const Text('Damaged / Rejected:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.redCritical)),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: _damagedQty.toInt().toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(suffixText: 'Bags'),
                            onChanged: (val) {
                              _damagedQty = double.tryParse(val) ?? 0;
                              _rejectedQty = _damagedQty;
                              _recalcQuantities();
                            },
                          ),
                        ),
                      ],
                    ),

                    if (_rejectedQty > 0) ...[
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _rejectionReasonCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Rejection Reason (Defect Description)',
                          prefixIcon: Icon(Icons.report_gmailerrorred_rounded, color: AppColors.redCritical),
                        ),
                      ),
                    ],

                    const Divider(height: 24),

                    // Net Accepted Result
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Net Sound Accepted Quantity:',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.emeraldSuccess),
                          ),
                          Text(
                            '$_acceptedQty Bags',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.emeraldSuccess),
                          ),
                        ],
                      ),
                    ),

                    // Discrepancy Alert Indicator
                    if (_deliveredQty < _orderedQty || _damagedQty > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.redBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.redCritical.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.redCritical, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _deliveredQty < _orderedQty
                                    ? 'Auto-Discrepancy: ${(_orderedQty - _deliveredQty).toInt()} bags shortage detected!'
                                    : 'Auto-Discrepancy: ${_damagedQty.toInt()} damaged bags will be flagged for credit note.',
                                style: const TextStyle(color: AppColors.redCritical, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Step 4: Photo Evidence & Verification
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '4. Photo Evidence & Audit Trail',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _attachedWaybill,
                      onChanged: (v) => setState(() => _attachedWaybill = v ?? false),
                      title: const Text('Signed Supplier Waybill Attached', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Waybill # WB-MUG-91024', style: TextStyle(fontSize: 11)),
                      secondary: const Icon(Icons.document_scanner_rounded, color: AppColors.electricBlue),
                      dense: true,
                    ),
                    CheckboxListTile(
                      value: _attachedTruckPlate,
                      onChanged: (v) => setState(() => _attachedTruckPlate = v ?? false),
                      title: const Text('Truck License Plate Photo Attached', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Scale gate photo: ET-3-77219-AA', style: TextStyle(fontSize: 11)),
                      secondary: const Icon(Icons.camera_alt_outlined, color: AppColors.electricBlue),
                      dense: true,
                    ),
                    CheckboxListTile(
                      value: _attachedDamagePhoto,
                      onChanged: (v) => setState(() => _attachedDamagePhoto = v ?? false),
                      title: const Text('Damage Inspection Close-Up Attached', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Pallet moisture evidence', style: TextStyle(fontSize: 11)),
                      secondary: const Icon(Icons.broken_image_outlined, color: AppColors.redCritical),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.emeraldSuccess,
              ),
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Verify Delivery & Issue Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tallyTile({required String label, required String value, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
        ],
      ),
    );
  }
}
