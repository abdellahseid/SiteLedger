import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/material_progress_bar.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isApproving = false;

  void _handleApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Purchase Order'),
        content: const Text('Are you sure you want to approve this purchase order? This authorizes site storekeepers to accept incoming material shipments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldSuccess),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isApproving = true);
      try {
        await ref.read(orderRepoProvider).approveOrder(widget.orderId);
        ref.invalidate(ordersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Purchase order approved successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve order: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isApproving = false);
      }
    }
  }

  void _showQrDialog(String poNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(poNumber),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 180, color: AppColors.navyDark),
            ),
            const SizedBox(height: 12),
            const Text(
              'Present this QR code or PO number at site scale gate for rapid material intake.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderFuture = ref.watch(orderRepoProvider).getOrderDetails(widget.orderId);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: FutureBuilder(
        future: orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading order: ${snapshot.error}'));
          }

          final po = snapshot.data!;
          final canApprove = (user?.isProjectManager == true) && po.status == 'PENDING_APPROVAL';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                po.poNumber,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                              ),
                              Text(
                                po.projectName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          StatusBadge(status: po.status),
                        ],
                      ),
                      const Divider(height: 28),
                      _detailRow('Supplier', po.supplierName),
                      if (po.supplierPhone != null) _detailRow('Supplier Contact', po.supplierPhone!),
                      _detailRow('Total Commitment', Formatters.currency(po.totalAmountEtb)),
                      _detailRow('Created By', po.createdByName ?? 'Dawit Tadesse (Procurement)'),
                      if (po.approvedByName != null) _detailRow('Approved By', po.approvedByName!),
                      _detailRow('Date Created', Formatters.date(po.createdAt)),
                      if (po.notes != null) _detailRow('Notes', po.notes!),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _showQrDialog(po.poNumber),
                        icon: const Icon(Icons.qr_code_rounded, size: 18),
                        label: const Text('View Order QR Code'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              if (canApprove) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldSuccess,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isApproving ? null : _handleApprove,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: _isApproving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Approve Purchase Order (Sign-off)'),
                ),
                const SizedBox(height: 12),
              ],

              if (po.canReceive) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => context.push('/receive', extra: po),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Start Material Receiving'),
                ),
                const SizedBox(height: 16),
              ],

              // Line Items
              const Text(
                'Materials Ordered',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.navyDark),
              ),
              const SizedBox(height: 8),

              ...po.lines.map((line) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                line.materialName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.navyDark),
                              ),
                            ),
                            Text(
                              Formatters.currency(line.totalPriceEtb),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.electricBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Unit Price: ${Formatters.currency(line.unitPriceEtb)} / ${line.unit}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        MaterialProgressBar(
                          ordered: line.orderedQuantity,
                          accepted: line.acceptedQuantity,
                          unit: line.unit,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyDark),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
